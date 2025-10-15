export Frame

@gtakwidgetcomponent Frame <: GtakWidgetComponent begin
    const box::SubParams = SubParams()

    const children::Components = []
    const innerbox = Box(; box..., children)
end

params(::Type{Frame}) = Set{Symbol}([:box])

function mount!(f::Frame, p::GtakComponent)
    f.parent = p
    f.widget = GtkFrame()
    f.widget[] = mount!(f.innerbox, f)
    return f.widget
end

function unmount!(f::Frame)
    unmount!(f.innerbox)
    return _gtakunmountwidget!(f)
end
