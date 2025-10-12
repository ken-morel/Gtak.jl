export Frame

@gtakcomponent Frame <: GtakWidgetComponent begin
    const box::SubParams = SubParams()

    const children::Components = []
    const innerbox = Box(; box..., children)
end

function IonicEfus.mount!(f::Frame, p::GtakComponent)
    f.parent = p
    f.widget = GtkFrame()
    f.widget[] = mount!(f.innerbox, f)
    empty!(f.children)
    return f.widget
end

function IonicEfus.unmount!(f::Frame)
    unmount!(f.box)
    return _gtakunmountwidget!(f)
end
