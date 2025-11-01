export Box, HBox, VBox

"""
    Box(; orient=Gtk4.Orientation_VERTICAL, spacing=nothing, homogeneous=nothing, kwargs...)

A container that packs its children in a single row or column.

`HBox(...)` is a convenience constructor for a horizontal box (`orient=Gtk4.Orientation_HORIZONTAL`).
`VBox(...)` is a convenience constructor for a vertical box (`orient=Gtk4.Orientation_VERTICAL`).
"""
@gtakwidgetcomponent Box  begin
    "The orientation of the box: `Gtk4.Orientation_HORIZONTAL` or `Gtk4.Orientation_VERTICAL`."
    orient::Gtk4.Orientation = Gtk4.Orientation_VERTICAL
    "The spacing between children in pixels."
    spacing::Union{MayBeReactive{Int}, Nothing} = nothing
    "Whether all children should be allocated the same size."
    homogeneous::Union{MayBeReactive{Bool}, Nothing} = nothing

    const children::Vector{Component} = []
end

Gtk4.GtkBox(o::Orientation) = GtkBox(o === O_V ? :v : :h)


HBox(; args...) = Box(; orient = O_H, args...)
VBox(; args...) = Box(; orient = O_V, args...)

function mount!(b::Box, p::GtakComponent)
    @lock b begin
        b._parent = p
        b._widget = GtkBox(b.orient)
        _gtakwidgetmountcommon!(b, [])
        for child in b.children
            widget = mount!(child, b)
            push!(b._widget, widget)
        end
        return b._widget
    end
end

function update!(b::Box)
    return _updates(b) do dirt
        if dirt == :spacing && !isnothing(b.spacing)
            b._widget.spacing = resolve(Int, b.spacing)
        elseif dirt == :homogeneous && !isnothing(b.homogeneous)
            b._widget.homogeneous = resolve(Bool, b.homogeneous)
        end
    end
end
