export Separator

"""
    Separator(; orient=Gtk4.Orientation_HORIZONTAL, kwargs...)

A widget that displays a horizontal or vertical line to separate other widgets.
"""
@gtakwidgetcomponent struct Separator
    "The orientation of the separator: `Gtk4.Orientation_HORIZONTAL` or `Gtk4.Orientation_VERTICAL`."
    orient::MayBeReactive{Gtk4.Orientation} = O_H
end


function mount!(s::Separator, p::GtakComponent)
    @lock s begin
        s._parent = p
        s._widget = GtkSeparator(resolve(Gtk4.Orientation, s.orient))
        _gtakwidgetmountcommon!(s, [])
        return s._widget
    end
end

function update!(l::Separator)
    return _updates(l) do dirt
        if dirt == :orient
            l._widget.orientation = resolve(Gtk4.Orientation, l.orient)
        end
    end
end
