export For
const _RLCache = Tuple{Any, Components, Vector{<:GtkWidget}}

"""
    For(; items, builder, remount=false, rebuild=false, box=SubParams(), kwargs...)

A control flow component that iterates over a collection of `items` and renders a set of components for each item.

It efficiently updates, adds, or removes items from the UI when the `items` collection changes.

**Fields**
- `items`: A reactive collection (e.g., `Vector`, `Reactant{Vector}`) to iterate over.
- `builder::Function`: A function that takes a single item from `items` and returns a `Component` or `Components` to render for that item.
- `remount::Bool`: If `true`, components are unmounted and remounted when `items` change, even if the item itself hasn't changed.
- `rebuild::Bool`: If `true`, the `builder` function is re-executed for existing items when `items` change.
- `box::SubParams`: Parameters to pass to the internal `Box` container that holds the rendered items.
"""
@gtakcomponent struct For <: GtakComponent
    items::MayBeReactive{<:AbstractVector}
    builder::Function
    remount::MayBeReactive{Bool} = false
    rebuild::MayBeReactive{Bool} = false
    const box = SubParams()

    const innerbox::Box = Box(; box...)
    _cache::Vector{_RLCache} = []
end

function Efus.mount!(l::For, p::GtakComponent)
    @lock l begin
        l._parent = p
        l._widget = mount!(l.innerbox, l)
        for item in resolve(l.items)
            new_cache_item = _build_item(l, item)
            push!(l._cache, new_cache_item)
            push!(l.innerbox._widget, new_cache_item[3]...)
        end

        l.items isa AbstractReactive && oncollectionchange(l._catalyst, l.items) do compute_diff, _
            schedule(
                l, Sched.ComponentUpdate(l, Sched.Normal) do
                    changes = compute_diff() # This computes the diff
                    @lock l begin
                        for change in changes
                            _handle_collection_change(l, change)
                        end
                    end
                end
            )

        end

        return l._widget
    end
end


function _build_item(l::For, item)
    components = @invokelatest l.builder(item)
    widgets = GtkWidget[mount!(c, l.innerbox) for c in components]
    return _RLCache((item, components, widgets))
end

function _rebuild_box_content(l::For)
    gmain() do
        empty!(l.innerbox._widget)
        for (_, _, widgets) in l._cache
            push!(l.innerbox._widget, widgets...)
        end
    end
    return
end

# --- `_handle_collection_change` methods using multiple dispatch ---

function _handle_collection_change(l::For, change::Ionic.Push)
    cache = []
    for item in change.values
        new_cache_item = _build_item(l, item)
        push!(l._cache, new_cache_item)
        push!(cache, new_cache_item[3]...)
    end
    isempty(cache) || gmain() do
        push!(l.innerbox._widget, cache...)
    end
    return
end

function _handle_collection_change(l::For, change::Ionic.Pop)
    todelete = []
    for _ in 1:change.count
        if !isempty(l._cache)
            (_, components, widgets) = pop!(l._cache)
            unmount!.(components)
            isempty(widgets) || push!(todelete, widgets...)
        end
    end
    gmain() do
        for w in todelete
            Gtk4.delete!(l.innerbox._widget, w)
        end
    end
    return
end

function _handle_collection_change(l::For, change::Ionic.Replace)
    return if 1 <= change.index <= length(l._cache)
        # Unmount old
        (_, old_components, _) = l._cache[change.index]
        unmount!.(old_components)

        # Build and replace in cache
        new_cache_item = _build_item(l, change.value)
        l._cache[change.index] = new_cache_item

        # A full rebuild is simplest for UI replacement
        _rebuild_box_content(l)
    end
end

function _handle_collection_change(l::For, change::Ionic.Insert)
    new_cache_item = _build_item(l, change.value)
    insert!(l._cache, change.index, new_cache_item)
    # GtkBox has no simple insert, so rebuild
    return _rebuild_box_content(l)
end

function _handle_collection_change(l::For, change::Ionic.DeleteAt)
    todelete = []
    if 1 <= change.index <= length(l._cache)
        (_, components, widgets) = splice!(l._cache, change.index)
        unmount!.(components)
        isempty(widgets) || push!(todelete, widgets...)

    end
    return isempty(todelete) || gmain() do
        for w in todelete
            Gtk4.delete!(l.innerbox._widget, w)
        end
    end
end

function _handle_collection_change(l::For, change::Ionic.Move)
    # This is a significant optimization using GtkBox reordering
    for (from, to) in change.moves
        # Reorder cache
        cache_item = splice!(l._cache, from)
        insert!(l._cache, to, cache_item)
        return _rebuild_box_content(l)
    end
    return
end

function _handle_collection_change(l::For, change::Ionic.Empty)
    for (_, components, _) in l._cache
        unmount!.(components)
    end
    empty!(l._cache)
    return gmain(() -> empty!(l.innerbox._widget))
end

function Efus.unmount!(l::For)
    for (_, components, _) in l._cache
        unmount!.(components)
    end
    unmount!(l.innerbox)
    denature!(l._catalyst)
    empty!(l._cache)
    empty!(l._dirty)
    l._widget = nothing
    l._parent = nothing
    return
end
