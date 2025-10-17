export Separator

@gtakwidgetcomponent Separator <: GtakWidgetComponent begin
    orient::MayBeReactive{Gtk4.Orientation} = O_H
end


function mount!(s::Separator, p::GtakComponent)
    s._parent = p
    s._widget = GtkSeparator(resolve(Gtk4.Orientation, s.orient))
    _gtakwidgetmountcommon!(b, [])
    return s._widget
end

function update!(l::Separator)
    return _updates(l) do dirt
        if dirt == :orient
            l._widget.orientation = resolve(Gtk4.Orientation, l.orient)
        end
    end
end
