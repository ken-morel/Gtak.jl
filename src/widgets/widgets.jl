export GtakComponent, scheduleupdate, getpage
abstract type GtakWidgetComponent <: GtakComponent end


macro gtakwidgetcomponent(name::Expr, block)
    return esc(
        quote
            @gtakcomponent $name begin
                opacity::Union{Float32, Nothing} = 1
                margin::Union{Int, NTuple{2, Int}, NTuple{4, Int}, Nothing} = nothing
                align::Union{NTuple{2, Gtk4.Align}, Nothing} = nothing
                expand::Union{Symbol, Nothing} = nothing
                canfocus::Union{Bool, Nothing} = nothing
                cursor::Union{GdkCursor, Nothing} = nothing
                sensitive::Union{Bool, Nothing} = nothing
                tooltip::Union{AbstractString, Nothing} = nothing
                $(LineNumberNode(__source__.line, __source__.file))
                $block
            end
        end
    )
end

include("./label.jl")
include("./button.jl")
include("./box.jl")
include("./entry.jl")
include("./spinner.jl")
include("./separator.jl")
include("./grid.jl")
include("./frame.jl")
include("./togglebutton.jl")
include("./checkbutton.jl")
include("./switch.jl")
include("./linkbutton.jl")


getparent(p::GtakComponent) = hasproperty(p, :parent) ? p.parent : nothing
getchildren(p::GtakComponent) = hasproperty(p, :children) ? p.children : nothing

function getpage(c::GtakComponent)
    current = c
    while !isa(current, AbstractPage) && (parent = getparent(current)) !== nothing && parent !== current
        current = parent
        current isa AbstractPage && return current
    end
    return
end

isdirty(c::GtakComponent) = hasproperty(c, :dirty) && !isempty(c.dirty)

unmount!(c::GtakWidgetComponent) = _gtakunmountwidget!(c)

function _gtakunmountwidget!(c::GtakComponent; widgets::Vector{Symbol} = Symbol[:widget])
    @lock c.lock begin
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
                if parent isa GtkFrame || parent isa GtkButton
                    parent[] = nothing
                elseif !isnothing(parent)
                    try
                        delete!(parent, widget_obj)
                    catch e
                        @warn "Error removing widget $(typeof(widgets)) from parent of type $(typeof(parent)) using delete" exception = e
                    end
                end
                setproperty!(c, widget, nothing)
            end
        end
    end
    return
end

function _trackreactiveattributes(c::GtakComponent)
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
function _updates(fn::Function, c::Component)
    !ismounted(c) && return
    @lock c.lock while !isempty(c.dirty)
        key = pop!(c.dirty)
        fn(key)
    end
    return
end
function scheduleupdate(c::GtakComponent, priority::Sched.Priority = Sched.Normal)
    page = getpage(c)
    return if !isnothing(page) && !isnothing(page.scheduler)

        schedule!(page.scheduler, Sched.ComponentUpdate(c, priority))
    end
end

function dirty!(c::GtakComponent, attr::Symbol, priority::Union{Sched.Priority, Nothing} = Sched.Normal)
    @lock c.lock if hasproperty(c, :dirty)
        push!(c.dirty, attr)
        !isnothing(priority) && scheduleupdate(c, priority)
    end
    return
end
function dirty!(c::GtakComponent, attr::Symbol, value, priority::Union{Sched.Priority, Nothing} = Sched.Normal)
    @lock c.lock if hasproperty(c, attr)
        setfield!(c, attr, value)
        dirty!(c, attr, priority)
    end
    return
end

ismounted(c::GtakComponent) = !isnothing(c.widget)

function Base.schedule(c::GtakComponent, task::Sched.AbstractPriorityTask)
    p = getpage(c)
    isnothing(p) && return
    return schedule(p, task)
end
function getcomponentlayout(c::Component)
    return if hasproperty(c, :lay) && c.lay isa SubParams
        c.lay
    else
        SubParams()
    end
end
