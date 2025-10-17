export Label

@gtakwidgetcomponent Label <: GtakWidgetComponent begin
    text::MayBeReactive{String} = ""
    selectable::Union{MayBeReactive{Bool}, Nothing} = nothing
    justify::Union{MayBeReactive{Gtk4.Justification}, Nothing} = nothing
    wrap::Union{MayBeReactive{Bool}, Nothing} = nothing
end


function mount!(l::Label, p::GtakComponent)::GtkLabel
    l._parent = p
    l._widget = GtkLabel(resolve(AbstractString, l.text))
    _gtakwidgetmountcommon!(b, [])
    return l._widget
end

function update!(l::Label)
    return _updates(l) do dirt
        if dirt == :text
            Gtk4.markup(l.widget, resolve(String, l.text))
        elseif dirt == :selectable && !isnothing(l.selectable)
            Gtk4.selectable(l.widget, resolve(Bool, l.selectable))
        elseif dirt == :justify && !isnothing(l.justify)
            Gtk4.justify(l.widget, resolve(Gtk4.Justification, l.justify))
        elseif dirt == :wrap && !isnothing(l.wrap)
            Gtk4.wrap(l.widget, resolve(Bool, l.wrap))
        end
    end
end
