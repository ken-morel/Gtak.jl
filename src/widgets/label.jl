export Label

Base.@kwdef mutable struct Label <: GtakComponent
    text::MayBeReactive{String} = ""
    selectable::MayBeReactive{Bool} = false
    justify::MayBeReactive{Gtk4.Justification} = JL
    wrap::MayBeReactive{Bool} = true

    widget::Union{GtkLabel, Nothing} = nothing
    parent::Union{GtakComponent, Nothing} = nothing
    dirty::Set{Symbol} = Set()

    const catalyst::Catalyst = Catalyst()
end


function mount!(l::Label, p::GtakComponent)::GtkLabel
    l.parent = p
    l.widget = GtkLabel(resolve(AbstractString, l.text))
    Gtk4.markup(l.widget, resolve(AbstractString, l.text))
    Gtk4.selectable(l.widget, l.selectable)
    Gtk4.justify(l.widget, l.justify)
    Gtk4.wrap(l.widget, l.wrap)

    _trackreactiveattributes(l)
    return l.widget
end

params(::Type{Label}) = [:text, :selectable, :justify, :wrap]
function update!(l::Label)
    _updates(l) do dirt
        if dirt == :text
            Gtk4.markup(l.widget, resolve(String, l.text))
        elseif dirt == :selectable
            Gtk4.selectable(l.widget, resolve(Bool, l.selectable))
        elseif dirt == :justify
            Gtk4.justify(l.widget, l.justify)
        elseif dirt == :wrap
            Gtk4.wrap(l.widget, l.wrap)
        end
    end
    return
end

function unmount!(l::Label)
    _gtakunmountwidget!(l)
    return
end
