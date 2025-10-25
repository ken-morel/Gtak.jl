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
    items = resolve(l.items)
    final = Vector{_RLCache}()
    rebuild = resolve(Bool, l.rebuild)
    remount = resolve(Bool, l.remount)
    println(" --- placing items ---")
    @time for item in items
        cacherowidx = 0
        for (rowidx, (rowitem, _, rowwidgets)) in enumerate(l._cache)
            if rowitem === item
                cacherowidx = rowidx
                break
            else
                for widget in rowwidgets
                    p = Gtk4.parent(widget)
                    !isnothing(p) && Gtk4.delete!(p, widget)
                end
            end
        end
        components = widgets = nothing
        if cacherowidx > 0
            item, components, widgets = popat!(l._cache, cacherowidx)
        end
        println("Maybe building")
        @time if rebuild || isnothing(components)
            components = @invokelatest l.builder(item)
        end
        println("Mounting them")
        @time if remount || isnothing(widgets)
            widgets = [mount!(c, l.innerbox) for c in components]
        end
        println("placing widgets")
        @time for widget in widgets
            if Gtk4.parent(widget) != l._widget
                push!(l._widget, widget)
            end
        end
        println("Pushing to list")
        push!(final, (item, components, widgets))
    end
    println("Unmounting cache")
    @time while !isempty(l._cache)
        c = pop!(l._cache)[2]
        unmount!.(c)
    end
    append!(l._cache, final)
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
