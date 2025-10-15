export ForBox
const _RLCache = Tuple{Any, Components, Vector{<:GtkWidget}}

@gtakcomponent ForBox <: GtakComponent begin
    items::MayBeReactive
    builder::Function
    remount::Bool = false
    rebuild::Bool = false
    const box = SubParams()


    innerbox::Box = Box(; box...)
    _cache::Vector{_RLCache} = []
end
IonicEfus.params(::ForBox) = Set{Symbol}([:items, :builder, :box])

function IonicEfus.mount!(l::ForBox, p::GtakComponent)
    l.parent = p
    l.items isa AbstractReactive && catalyze!(l.catalyst, l.items) do _
        dirty!(l, :items)
    end
    l.widget = mount!(l.innerbox, l)
    updatecontent!(l)
    return l.widget
end
function IonicEfus.update!(l::ForBox)
    return _updates(l) do key
        if key == :items
            updatecontent!(l)
        end
    end
end

function updatecontent!(l::ForBox)
    items = resolve(l.items)
    final = Vector{_RLCache}()
    for item in items
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
        if l.rebuild || isnothing(components)
            components = @invokelatest l.builder(item)
        end
        if l.remount || isnothing(widgets)
            widgets = [mount!(c, l.innerbox) for c in components]
        end
        for widget in widgets
            if Gtk4.parent(widget) != l.widget
                push!(l.widget, widget)
            end
        end
        push!(final, (item, components, widgets))
    end
    while !isempty(l._cache)
        c = pop!(l._cache)[2]
        unmount!.(c)
    end
    append!(l._cache, final)
    return
end
function IonicEfus.unmount!(l::ForBox)
    unmount!(l.innerbox)
    denature!(l.catalyst)
    empty!(l._cache)
    empty!(l.dirty)
    l.widget = nothing
    l.parent = nothing
    return
end
