export GtakComponent, scheduleupdate, getpage
abstract type GtakWidgetComponent <: GtakComponent end


macro gtakwidgetcomponent(def)
    @assert def.head == :struct
    base = quote
        # "The opacity of the widget, from 0.0 (fully transparent) to 1.0 (fully opaque)."
        opacity::Union{MayBeReactive{<:Real}, Nothing} = nothing
        # "Sets the margin around the widget. Can be an `Int` for all sides, a `(vertical, horizontal)` tuple, or a `(top, right, bottom, left)` tuple."
        margin::Union{MayBeReactive{Union{Int, NTuple{2, Int}, NTuple{4, Int}}}, Nothing} =
            nothing
        # "Sets the vertical and horizontal alignment of the widget within its allocated space. Can be a `Gtk4.Align` value or a `(vertical, horizontal)` tuple."
        align::Union{
            MayBeReactive{<:Union{<:NTuple{2, Union{Gtk4.Align, Nothing}}, Gtk4.Align}},
            Nothing,
        } = nothing
        # "Whether the widget should expand to fill extra space. Can be a `Bool` for both directions or a `(vertical, horizontal)` tuple."
        expand::Union{MayBeReactive{Union{NTuple{2, Bool}, Bool}}, Nothing} = nothing
        # "Whether the widget can receive keyboard focus."
        canfocus::Union{MayBeReactive{Bool}, Nothing} = nothing
        # "Whether the widget currently has keyboard focus."
        hasfocus::Union{MayBeReactive{Bool}, Nothing} = nothing
        # "The mouse cursor to display when hovering over the widget."
        cursor::Union{MayBeReactive{GdkCursor}, Nothing} = nothing
        # "Whether the widget is sensitive to user input."
        sensitive::Union{MayBeReactive{Bool}, Nothing} = nothing
        # "A tooltip to display when hovering over the widget. Supports Pango markup."
        tooltip::Union{MayBeReactive{<:AbstractString}, Nothing} = nothing
        # "Whether the widget is visible."
        visible::Union{MayBeReactive{Bool}, Nothing} = nothing
        # "A list of CSS classes to apply to the widget for styling."
        cssclasses::Union{MayBeReactive{<:AbstractVector{<:AbstractString}}, Nothing} =
            nothing
        # "The CSS name to apply to the widget, used for styling."
        cssname::Union{MayBeReactive{<:AbstractString}, Nothing} = nothing
        # "The desired width of the widget."
        width_request::Union{MayBeReactive{<:Integer}, Nothing} = nothing
        # "The desired height of the widget."
        height_request::Union{MayBeReactive{<:Integer}, Nothing} = nothing
        # "Parameters for layout managers like `Grid` (e.g., `lay:pos=(1,2)`)."
        lay::SubParams = SubParams()
    end
    if def.args[2] isa Symbol
        def.args[2] = Expr(:<:, def.args[2], :GtakWidgetComponent)
    end
    append!(def.args[3].args, base.args[2:end])
    return esc(
        Expr(
            :macrocall,
            Symbol("@gtakcomponent"),
            LineNumberNode(__source__.line, __source__.file),
            def,
        ),
    )
end

const _gtak_common = Set(
    [
        :opacity,
        :margin,
        :align,
        :expand,
        :canfocus,
        :hasfocus,
        :cursor,
        :sensitive,
        :tooltip,
        :visible,
        :cssclasses,
        :cssname,
        :width_request,
        :height_request,
    ]
)
function _gtakwidgetupdatecommon(c::C, w::GtkWidget, k::Symbol, v) where {C <: GtakComponent}
    if k == :margin
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
    elseif k in Set(
            [
                :canfocus,
                :opacity,
                :sensitive,
                :cursor,
                :visible,
                :width_request,
                :height_request,
            ]
        )
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

    return
end

function _updates(fn::Function, c::Component)
    return @lock c begin
        if ismounted(c)
            # gmain() do
            while !isempty(c._dirty)
                key = pop!(c._dirty)
                if key in _gtak_common
                    val = getproperty(c, key)

                    isnothing(val) ||
                        _gtakwidgetupdatecommon(c, c._widget, key, resolve(val))
                else
                    fn(key)
                end
                # end
            end
        end
    end
end
update!(c::GtakComponent) = _updates(identity, c)
function _gtakwidgetmountcommon!(c, donttrack::Vector)
    @lock c begin
        for (name,) in params(c)
            dirty!(c, name; priority = nothing)
            @assert !isnothing(c._widget) "$name errored amongst $(params(c))"
        end
        _trackreactiveattributes(c, donttrack)
        schedule(c, Sched.ComponentUpdate(c, Sched.High))
    end
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
include("./menu.jl")
include("./menubutton.jl")


@generated getparent(c::GtakComponent) = hasfield(c, :_parent) ? :(c._parent) : nothing
@generated getchildren(p::GtakComponent) = hasfield(p, :children) ? :(p.children) : nothing
@generated isdirty(c::GtakComponent) = hasfield(c, :_dirty) ? :(!isempty(c._dirty)) : :false

ismounted(c::GtakComponent) = !isnothing(c._widget)

function getpage(c::GtakComponent)
    current = c
    while !isa(current, AbstractPage) &&
            (parent = getparent(current)) !== nothing &&
            parent !== current
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
        for widgetprop in widgets
            widget = getproperty(c, widgetprop)
            if !isnothing(widget)
                parent = Gtk4.parent(widget)
                if !isnothing(parent)
                    try
                        if parent isa Gtk4.GtkFrame ||
                                parent isa Gtk4.GtkButton ||
                                parent isa Gtk4.GtkScrolledWindow
                            Gtk4.set_child(parent, nothing)
                        elseif parent isa Gtk4.GtkPaned
                            if Gtk4.get_start_child(parent) == widget
                                Gtk4.set_start_child!(parent, nothing)
                            elseif Gtk4.get_end_child(parent) == widget
                                Gtk4.set_end_child!(parent, nothing)
                            end
                        elseif parent isa Gtk4.GtkNotebook
                            for i in 0:(Gtk4.get_n_pages(parent) - 1)
                                if Gtk4.get_nth_page(parent, i) == widget
                                    Gtk4.remove_page(parent, i)
                                    break
                                end
                            end
                        else
                            # Fallback to delete! for GtkBox, GtkGrid, and others
                            delete!(parent, widget)
                        end
                    catch
                    end
                end
                setproperty!(c, widgetprop, nothing)
            end
        end
        return
    end
end


function scheduleupdate(c::GtakComponent, priority::Sched.Priority = Sched.Normal)
    page = getpage(c)
    return if !isnothing(page) && !isnothing(getscheduler(page))
        schedule!(getscheduler(page), Sched.ComponentUpdate(c, priority))
    end
end

function dirty!(
        c::GtakComponent,
        attr::Symbol;
        priority::Union{Sched.Priority, Nothing} = Sched.Normal,
    )
    @lock c begin
        push!(c._dirty, attr)
        !isnothing(priority) && scheduleupdate(c, priority)
    end
    return
end
function dirty!(
        c::GtakComponent,
        attr::Symbol,
        value;
        priority::Union{Sched.Priority, Nothing} = Sched.Normal,
    )
    @lock c begin
        setproperty!(c, attr, value)
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
    return @lock c begin
        if hasproperty(c, :lay) && c.lay isa SubParams
            c.lay
        end
    end
end
