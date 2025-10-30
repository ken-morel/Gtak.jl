export Frame

@gtakwidgetcomponent Frame  begin

    const children::Components = []
end


function mount!(f::Frame, p::GtakComponent)
    @lock f begin
        f._parent = p
        f._widget = GtkFrame()
        _gtakwidgetmountcommon!(f, [])
        if length(f.children) > 0
            f._widget[] = mount!(f.children[1], f)
            if length(f.children) > 1
                @warn "Frame cannot have more than one child"
            end
        end
        return f._widget
    end
end


## - BoxFrame

export BoxFrame

@gtakwidgetcomponent BoxFrame  begin
    const box::SubParams = SubParams()

    const children::Components = []
    const _innerbox = Box(; box..., children)
end


function mount!(f::BoxFrame, p::GtakComponent)
    @lock f begin
        f._parent = p
        f._widget = GtkFrame()
        _gtakwidgetmountcommon!(f, [])
        f._widget[] = mount!(f._innerbox, f)
        return f._widget
    end
end

function unmount!(f::BoxFrame)
    @lock f begin
        unmount!(f._innerbox)
        _gtakunmountwidget!(f)
    end
    return
end
