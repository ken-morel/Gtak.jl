export Spinner

@gtakwidgetcomponent Spinner <: GtakWidgetComponent begin
    spinning::MayBeReactive{Bool} = true
end

function mount!(s::Spinner, p::GtakComponent)
    s._parent = p
    s._widget = GtkSpinner()
    _gtakwidgetmountcommon!(b, [])
    return s._widget
end

function update!(s::Spinner)
    return _updates(s) do key
        if key == :spinning
            s._widget.spinning = resolve(Bool, s.spinning)
        end
    end
end
