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
    items::MayBeReactive
    builder::Function
    remount::MayBeReactive{Bool} = false
    rebuild::MayBeReactive{Bool} = false
    const box = SubParams()


    innerbox::Box = Box(; box...)
    _cache::Vector{_RLCache} = []
end

function Efus.mount!(l::For, p::GtakComponent)
    l._parent = p
    l.items isa AbstractReactive && catalyze!(l._catalyst, l.items) do _
        dirty!(l, :items)
    end
    l._widget = mount!(l.innerbox, l)
    updatecontent!(l)
    return l._widget
end
function Efus.update!(l::For)
    return _updates(l) do key
        if key == :items
            updatecontent!(l)
        end
    end
end

function updatecontent!(l::For)
    new_items = resolve(l.items)
    rebuild = resolve(l.rebuild)
    remount = resolve(l.remount)

    old_cache_map = Dict{Any, Tuple{Components, Vector{<:GtkWidget}}}()
    for (item, components, widgets) in l._cache
        old_cache_map[item] = (components, widgets)
    end

    # Clear the innerbox to re-add widgets in the correct order
    #
    widgetstoadd = GtkWidget[]

    final_cache = Vector{_RLCache}()

    for item in new_items
        components = nothing
        widgets = nothing

        if haskey(old_cache_map, item)
            (cached_components, cached_widgets) = pop!(old_cache_map, item)
            components = cached_components
            widgets = cached_widgets::Vector{<:GtkWidget}

            if rebuild
                unmount!.(components)
                components = @invokelatest l.builder(item)
                remount = true # Force remount if components were rebuilt
            end

            if remount || isnothing(widgets)
                # If remount is true or widgets were never mounted (e.g., initial build)
                unmount!.(cached_components) # Unmount old components if new ones are being mounted
                widgets = GtkWidget[mount!(c, l.innerbox) for c in components]
            end
        else
            # New item, build and mount
            components = @invokelatest l.builder(item)
            widgets = GtkWidget[mount!(c, l.innerbox) for c in components]
        end

        for widget in widgets
            push!(widgetstoadd, widget)
        end
        push!(final_cache, _RLCache((item, components, widgets)))
    end


    # Unmount components that are no longer in the new_items list
    for (_, (components, _)) in old_cache_map
        unmount!.(components)
    end

    empty!(l.innerbox._widget)
    !isempty(widgetstoadd) && push!(l.innerbox._widget, widgetstoadd...)

    l._cache = final_cache
    return
end
function Efus.unmount!(l::For)
    unmount!(l.innerbox)
    denature!(l._catalyst)
    empty!(l._cache)
    empty!(l._dirty)
    l._widget = nothing
    l._parent = nothing
    return
end
