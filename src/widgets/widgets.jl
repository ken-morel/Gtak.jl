include("./label.jl")
include("./button.jl")
include("./box.jl")
include("./entry.jl")

IonicEfus.getparent(p::GtakComponent) = hasproperty(p, :parent) ? p.parent : nothing
IonicEfus.getchildren(p::GtakComponent) = hasproperty(p, :children) ? p.children : nothing

function getpage(c::GtakComponent)
    current = c
    while (parent = getparent(current)) !== nothing && parent !== current && !isa(current, AbstractPage)
        current = parent
    end
    return if current isa AbstractPage
        current
    end
end
function IonicEfus.isdirty(c::GtakComponent)
    return hasproperty(c, :dirty) && !isempty(c.dirty)
end

function shaketree(c::GtakComponent)
    page = getpage(c)
    if !isnothing(page)
        refresh(page)
    end
    return
end

function _gtakunmountwidget!(c::GtakComponent; widgets::Vector{Symbol} = Symbol[:widget])
    c.parent = nothing
    denature!(c.catalyst)
    children = getchildren(c)
    if !isnothing(children)
        foreach(unmount!, c.children)
    end

    for widget in widgets
        if hasproperty(c, widget) && !isnothing(getfield(c, widget))
            widget_obj = getfield(c, widget)
            parent = Gtk4.parent(widget_obj)
            delete!(parent, widget_obj)
            setproperty!(c, widget, nothing)
        end
    end
    return
end

@inline function _trackreactiveattributes(c::GtakComponent)
    for attr in params(typeof(c))
        val = getfield(c, attr)
        if val isa AbstractReactive
            catalyze!(c.catalyst, val) do _
                dirty!(c, attr)
                return
            end
        end
    end
    return
end
function _updates(fn::Function, c::GtakComponent)
    !ismounted(c) && return
    while !isempty(c.dirty)
        key = pop!(c.dirty)
        fn(key)
    end
    return
end

@inline function IonicEfus.dirty!(c::GtakComponent, attr::Symbol)
    if hasproperty(c, :dirty)
        push!(c.dirty, attr)
    end
    return
end
@inline function IonicEfus.dirty!(c::GtakComponent, attr::Symbol, value)
    if hasproperty(c, attr)
        setfield!(c, attr, value)
        dirty!(c, attr)
    end
    return
end

ismounted(c::GtakComponent) = !isnothing(c.widget)
