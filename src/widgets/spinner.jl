export Spinner

"""
    Spinner(; spinning=true, kwargs...)

An animated widget that indicates activity.
"""
@gtakwidgetcomponent struct Spinner
    "Whether the spinner is currently spinning."
    spinning::MayBeReactive{Bool} = true
end

function mount!(s::Spinner, p::GtakComponent)
    @lock s begin
        s._parent = p
        s._widget = GtkSpinner()
        _gtakwidgetmountcommon!(s, [])
        return s._widget
    end
end

function update!(s::Spinner)
    return _updates(s) do key
        if key == :spinning
            s._widget.spinning = resolve(Bool, s.spinning)
        end
    end
end
