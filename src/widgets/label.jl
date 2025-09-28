export Label

Base.@kwdef mutable struct Label <: GtakComponent
    text::MayBeReactive{String} = ""
    selectable::Bool = true
    justify::Gtk4.Justification = JL
    wrap::Bool = true

    widget::Union{GtkLabel, Nothing} = nothing
    parent::Union{GtakComponent, Nothing} = nothing

    const catalyst::Catalyst = Catalyst()
end

function mount!(l::Label, p::GtakComponent)::GtkLabel
    l.parent = p
    l.widget = GtkLabel(resolve(String, l.text))
    Gtk4.markup(l.widget, resolve(String, l.text))
    Gtk4.selectable(l.widget, l.selectable)
    Gtk4.justify(l.widget, l.justify)
    Gtk4.wrap(l.widget, l.wrap)
    l.text isa AbstractReactive && catalyze!(l.catalyst, l.text) do r
        set_gtk_property!(l.widget, :label, getvalue(r))
    end
    return l.widget
end

function unmount!(l::Label)
    l.parent = nothing
    denature!(l.catalyst)
    if !isnothing(l.widget)
        destroy(l.widget)
    end
    return
end
