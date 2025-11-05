export Frame

"""
    Frame(; kwargs...)

A container that draws a frame around its child, with an optional label.
"""
@gtakwidgetcomponent struct Frame
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

"""
    BoxFrame(; box=SubParams(), kwargs...)

A `Frame` that contains a `Box` as its child, allowing for easy layout within the frame.

**Fields**
- `box::SubParams`: Parameters to pass to the internal `Box` component.
"""
@gtakwidgetcomponent struct BoxFrame
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
