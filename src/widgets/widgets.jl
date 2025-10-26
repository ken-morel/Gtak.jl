export GtakComponent, scheduleupdate, getpage
abstract type GtakWidgetComponent <: GtakComponent end


macro gtakwidgetcomponent(name::Symbol, block)
    return esc(
        quote
            @gtakcomponent $name <: GtakWidgetComponent  begin
                opacity::Union{MayBeReactive{Float64}, Nothing} = nothing
                margin::Union{MayBeReactive{Union{Int, NTuple{2, Int}, NTuple{4, Int}}}, Nothing} = nothing
                align::Union{MayBeReactive{<:Union{<:NTuple{2, Union{Gtk4.Align, Nothing}}, Gtk4.Align}}, Nothing} = nothing
                expand::Union{MayBeReactive{Union{NTuple{2, Bool}, Bool}}, Nothing} = nothing
                canfocus::Union{MayBeReactive{Bool}, Nothing} = nothing
                hasfocus::Union{MayBeReactive{Bool}, Nothing} = nothing
                cursor::Union{MayBeReactive{GdkCursor}, Nothing} = nothing
                sensitive::Union{MayBeReactive{Bool}, Nothing} = nothing
                tooltip::Union{MayBeReactive{String}, Nothing} = nothing
                visible::Union{MayBeReactive{Bool}, Nothing} = nothing
                cssclasses::Union{MayBeReactive{Vector{String}}, Nothing} = nothing
                cssname::Union{MayBeReactive{String}, Nothing} = nothing
                width_request::Union{MayBeReactive{Int}, Nothing} = nothing
                height_request::Union{MayBeReactive{Int}, Nothing} = nothing
                lay::SubParams = SubParams()
                $(LineNumberNode(__source__.line, __source__.file))
                $block
            end
        end
    )
end
const _gtak_common = Set(
    [
        :opacity, :margin, :align, :expand, :canfocus, :hasfocus, :cursor, :sensitive, :tooltip, :visible,
        :cssclasses, :cssname, :width_request, :height_request,
    ]
)
function _gtakwidgetupdatecommon(c::C, w::GtkWidget, k::Symbol, v) where {C <: GtakComponent}
    return if k == :margin
        if length(v) == 1
            w.margin_top = w.margin_bottom = w.margin_start = w.margin_end = v
        elseif length(v) == 2
            w.margin_top, w.margin_start = v
            w.margin_bottom, w.margin_end = v
        elseif length(v) == 4
            w.margin_top, w.margin_end, w.margin_bottom, w.margin_start = v
        else
            @warn "Component of type $C Invalid margin $v"
        end
    elseif k == :align
        if v isa Tuple
            v, h = v
            isnothing(v) || setproperty!(w, :valign, v)
            isnothing(h) || setproperty!(w, :halign, h)
        else
            w.valign = w.halign = v
        end
    elseif k == :expand
        if length(v) == 1
            w.hexpand = w.vexpand = v
        elseif length(v) == 2
            w.vexpand, w.hexpand = v
        else
            @warn "Component of type $C received invalid expand $v"
        end
    elseif k in Set([:canfocus, :opacity, :sensitive, :cursor, :visible, :width_request, :height_request])
        setproperty!(w, k, v)
        w.tooltip_markup = v
    elseif k == :cssclasses
        Gtk4.css_classes(w, v)
    elseif k == :cssname
        Gtk4.css_name(w, v)
    elseif k == :hasfocus
        if v
            Gtk4.grab_focus(w)
        else
            toplevel = Gtk4.Gtk.toplevel(w)
            if toplevel isa Gtk4.GtkWindow
                toplevel.focus = nothing
            end
        end
    end

end
for n in [:lock, :trylock, :unlock]
    @eval Base.$n(c::GtakComponent) = Base.$n(c._lock)
end
function _updates(fn::Function, c::Component)
    ismounted(c) || return
    @lock c while !isempty(c._dirty)
        key = pop!(c._dirty)
        if key in _gtak_common
            val = getproperty(c, key)

            isnothing(val) || _gtakwidgetupdatecommon(
                c,
                c._widget,
                key,
                val isa AbstractReactive
                    ? getvalue(val)
                    : val
            )
        else
            fn(key)
        end
    end
    return
end
update!(c::GtakComponent) = _updates(identity, c)
function _gtakwidgetmountcommon!(c, donttrack::Vector)
    @assert !isnothing(c._widget)
    for (name,) in params(c)
        dirty!(c, name)
    end
    update!(c)
    @assert !isnothing(c._widget)
    _trackreactiveattributes(c, donttrack)
    @assert !isnothing(c._widget)
    return
end
function _trackreactiveattributes(c::GtakComponent, skip::Vector = [])
    toskip = Set(skip)
    for (name,) in params(c)
        name in toskip && continue
        val = getfield(c, name)
        if val isa AbstractReactive
            catalyze!(c._catalyst, val) do _
                dirty!(c, name)
            end
        end
    end
    return
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
include("./image.jl")
include("./progressbar.jl")
include("./scale.jl")
include("./textview.jl")
include("./scrolledwindow.jl")
include("./comboboxtext.jl")
include("./notebook.jl")
include("./paned.jl")
include("./video.jl")


@generated getparent(c::GtakComponent) = hasfield(c, :_parent) ? :(c._parent) : nothing
@generated getchildren(p::GtakComponent) = hasfield(p, :children) ? :(p.children) : nothing
@generated isdirty(c::GtakComponent) = hasfield(c, :_dirty) ? :(!isempty(c._dirty)) : :false

ismounted(c::GtakComponent) = !isnothing(c._widget)

function getpage(c::GtakComponent)
    current = c
    while !isa(current, AbstractPage) && (parent = getparent(current)) !== nothing && parent !== current
        current = parent
        current isa AbstractPage && return current
    end
    return
end


unmount!(c::GtakWidgetComponent) = _gtakunmountwidget!(c)

function _gtakunmountwidget!(c::GtakComponent; widgets::Vector{Symbol} = Symbol[:_widget])
    @lock c begin
        c._parent = nothing
        denature!(c._catalyst)
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


function scheduleupdate(c::GtakComponent, priority::Sched.Priority = Sched.Normal)
    page = getpage(c)
    return if !isnothing(page) && !isnothing(getscheduler(page))
        schedule!(getscheduler(page), Sched.ComponentUpdate(c, priority))
    end
end

function dirty!(c::GtakComponent, attr::Symbol; priority::Union{Sched.Priority, Nothing} = Sched.Normal)
    @lock c if hasproperty(c, :_dirty)
        push!(c._dirty, attr)
        !isnothing(priority) && scheduleupdate(c, priority)
    end
    return
end
function dirty!(c::GtakComponent, attr::Symbol, value; priority::Union{Sched.Priority, Nothing} = Sched.Normal)
    @lock c if hasproperty(c, attr)
        setfield!(c, attr, value)
        dirty!(c, attr; priority)
    end
    return
end


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
