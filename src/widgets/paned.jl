export Paned, HPaned, VPaned

export Paned, HPaned, VPaned

"""
    Paned(; orient=Gtk4.Orientation_HORIZONTAL, position=nothing, wide_handle=nothing, kwargs...)

A container that divides its area into two resizable panes.

`HPaned(...)` is a convenience constructor for a horizontal paned (`orient=Gtk4.Orientation_HORIZONTAL`).
`VPaned(...)` is a convenience constructor for a vertical paned (`orient=Gtk4.Orientation_VERTICAL`).
"""
@gtakwidgetcomponent Paned begin
    "The orientation of the paned: `Gtk4.Orientation_HORIZONTAL` or `Gtk4.Orientation_VERTICAL`."
    orient::Gtk4.Orientation = O_H
    "The position of the divider between the two panes."
    position::Union{MayBeReactive{<:Integer}, Nothing} = nothing
    "Whether the handle should be wider for easier grabbing."
    wide_handle::Union{MayBeReactive{Bool}, Nothing} = nothing

    const children::Components = []
end

HPaned(; args...) = Paned(; orient = O_H, args...)
VPaned(; args...) = Paned(; orient = O_V, args...)

function mount!(pn::Paned, p::GtakComponent)
    @lock pn begin
        pn._parent = p
        pn._widget = GtkPaned(pn.orient)
        _gtakwidgetmountcommon!(pn, [])

        if length(pn.children) >= 1
            pn._widget.start_child = mount!(pn.children[1], pn)
        end
        if length(pn.children) >= 2
            pn._widget.end_child = mount!(pn.children[2], pn)
        end
        if length(pn.children) > 2
            @warn "Paned can only have two children."
        end

        return pn._widget
    end
end

function update!(pn::Paned)
    return _updates(pn) do dirt
        if dirt == :position && !isnothing(pn.position)
            pn._widget.position = resolve(pn.position)
        elseif dirt == :wide_handle && !isnothing(pn.wide_handle)
            pn._widget.wide_handle = resolve(pn.wide_handle)
        end
    end
end
