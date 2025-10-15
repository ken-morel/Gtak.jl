export Label

@gtakwidgetcomponent Label <: GtakWidgetComponent begin
    text::MayBeReactive{String} = ""
    selectable::MayBeReactive{Bool} = false
    justify::MayBeReactive{Gtk4.Justification} = J_L
    wrap::MayBeReactive{Bool} = true
end


function mount!(l::Label, p::GtakComponent)::GtkLabel
    l.parent = p
    l.widget = GtkLabel(resolve(AbstractString, l.text))
    push!(l.dirty, :text, :selectable, :justify, :wrap)
    update!(l)

    _trackreactiveattributes(l)
    return l.widget
end

params(::Type{Label}) = Set{Symbol}([:text, :selectable, :justify, :wrap])
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
