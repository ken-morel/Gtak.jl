export Frame

@gtakwidgetcomponent Frame  begin
    const box::SubParams = SubParams()

    const children::Components = []
    const _innerbox = Box(; box..., children)
end


function mount!(f::Frame, p::GtakComponent)
    @lock f begin
        f._parent = p
        f._widget = GtkFrame()
        _gtakwidgetmountcommon!(f, [])
        f._widget[] = mount!(f._innerbox, f)
        return f._widget
    end
end

function unmount!(f::Frame)
    @lock f begin
        unmount!(f._innerbox)
        _gtakunmountwidget!(f)
    end
    return
end
