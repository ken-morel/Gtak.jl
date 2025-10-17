export Frame

@gtakwidgetcomponent Frame <: GtakWidgetComponent begin
    const box::SubParams = SubParams()

    const children::Components = []
    const _innerbox = Box(; box..., children)
end


function mount!(f::Frame, p::GtakComponent)
    f._parent = p
    f._widget = GtkFrame()
    _gtakwidgetmountcommon!(b, [])
    f._widget[] = mount!(f._innerbox, f)
    return f.widget
end

function unmount!(f::Frame)
    unmount!(f._innerbox)
    return _gtakunmountwidget!(f)
end
