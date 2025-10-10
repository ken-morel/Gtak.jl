abstract type GtakWidgetComponent <: GtakComponent end

include("./label.jl")
include("./button.jl")
include("./box.jl")
include("./entry.jl")


IonicEfus.getparent(p::GtakWidgetComponent) = hasproperty(p, :parent) ? p.parent : nothing
IonicEfus.getchildren(p::GtakWidgetComponent) = hasproperty(p, :children) ? p.children : nothing

function getpage(c::GtakWidgetComponent)
    current = c
    while !isa(current, AbstractPage) && (parent = getparent(current)) !== nothing && parent !== current
        current = parent
        current isa AbstractPage && return current
    end
    return
end

IonicEfus.isdirty(c::GtakWidgetComponent) = hasproperty(c, :dirty) && !isempty(c.dirty)

function _gtakunmountwidget!(c::GtakWidgetComponent; widgets::Vector{Symbol} = Symbol[:widget])
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

function _trackreactiveattributes(c::GtakWidgetComponent)
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
function _updates(fn::Function, c::GtakWidgetComponent)
    !ismounted(c) && return
    while !isempty(c.dirty)
        key = pop!(c.dirty)
        fn(key)
    end
    return
end

function scheduleupdate(c::GtakWidgetComponent, priority::Atak.Priority = Atak.Normal)
    page = getpage(c)
    return if !isnothing(page) && !isnothing(page.scheduler)
        schedule!(page.scheduler, () -> IonicEfus.update!(c), priority)
    end
end

function IonicEfus.dirty!(c::GtakWidgetComponent, attr::Symbol, priority::Union{Atak.Priority, Nothing} = Atak.Normal)
    if hasproperty(c, :dirty)
        push!(c.dirty, attr)
        !isnothing(priority) &&scheduleupdate(c, priority)
    end
    return
end
function IonicEfus.dirty!(c::GtakWidgetComponent, attr::Symbol, value, priority::Union{Atak.Priority, Nothing} = Atak.Normal)
    if hasproperty(c, attr)
        setfield!(c, attr, value)
        dirty!(c, attr, priority)
    end
    return
end

ismounted(c::GtakWidgetComponent) = !isnothing(c.widget)

function Base.schedule(fn::Function, c::GtakWidgetComponent, priority::Atak.Priority)
    p = getpage(c)
    isnothing(p) && return
    return schedule(fn, p, priority)
end
