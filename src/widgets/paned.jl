export Paned, HPaned, VPaned

@gtakwidgetcomponent Paned begin
    orient::Gtk4.Orientation = O_H
    position::Union{MayBeReactive{Int}, Nothing} = nothing
    wide_handle::Union{MayBeReactive{Bool}, Nothing} = nothing

    const children::Components = []
end

HPaned(; args...) = Paned(; orient = O_H, args...)
VPaned(; args...) = Paned(; orient = O_V, args...)

function mount!(pn::Paned, p::GtakComponent)
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

function update!(pn::Paned)
    _updates(pn) do dirt
        if dirt == :position && !isnothing(pn.position)
            pn._widget.position = resolve(Int, pn.position)
        elseif dirt == :wide_handle && !isnothing(pn.wide_handle)
            pn._widget.wide_handle = resolve(Bool, pn.wide_handle)
        end
    end
end
