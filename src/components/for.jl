export For
const _RLCache = Tuple{Any, Components, Vector{<:GtkWidget}}

@gtakcomponent For <: GtakComponent begin
    items::MayBeReactive
    builder::Function
    remount::MayBeReactive{Bool} = false
    rebuild::MayBeReactive{Bool} = false
    const box = SubParams()


    innerbox::Box = Box(; box...)
    _cache::Vector{_RLCache} = []
end

function IonicEfus.mount!(l::For, p::GtakComponent)
    l._parent = p
    l.items isa AbstractReactive && catalyze!(l._catalyst, l.items) do _
        dirty!(l, :items)
    end
    l._widget = mount!(l.innerbox, l)
    updatecontent!(l)
    return l._widget
end
function IonicEfus.update!(l::For)
    return _updates(l) do key
        if key == :items
            updatecontent!(l)
        end
    end
end

function updatecontent!(l::For)
    new_items = resolve(l.items)
    rebuild = resolve(Bool, l.rebuild)
    remount = resolve(Bool, l.remount)

    old_cache_map = Dict{Any, Tuple{Components, Vector{<:GtkWidget}}}()
    for (item, components, widgets) in l._cache
        old_cache_map[item] = (components, widgets)
    end

    # Clear the innerbox to re-add widgets in the correct order
    empty!(l.innerbox._widget)

    final_cache = Vector{_RLCache}()

    for item in new_items
        components = nothing
        widgets = nothing

        if haskey(old_cache_map, item)
            # Item exists in old cache, try to reuse
            (cached_components, cached_widgets) = pop!(old_cache_map, item)
            components = cached_components
            widgets = cached_widgets

            if rebuild
                unmount!.(components)
                components = @invokelatest l.builder(item)
                remount = true # Force remount if components were rebuilt
            end

            if remount || isnothing(widgets)
                # If remount is true or widgets were never mounted (e.g., initial build)
                unmount!.(cached_components) # Unmount old components if new ones are being mounted
                widgets = [mount!(c, l.innerbox) for c in components]
            end
        else
            # New item, build and mount
            components = @invokelatest l.builder(item)
            widgets = [mount!(c, l.innerbox) for c in components]
        end

        # Add widgets to the innerbox in the correct order
        for widget in widgets
            push!(l.innerbox._widget, widget)
        end
        push!(final_cache, (item, components, widgets))
    end

    # Unmount components that are no longer in the new_items list
    for (_, (components, _)) in old_cache_map
        unmount!.(components)
    end

    l._cache = final_cache
    return
end
function IonicEfus.unmount!(l::For)
    unmount!(l.innerbox)
    denature!(l._catalyst)
    empty!(l._cache)
    empty!(l._dirty)
    l._widget = nothing
    l._parent = nothing
    return
end
