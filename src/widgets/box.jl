export Box, HBox, VBox

Base.@kwdef mutable struct Box <: GtakComponent
    orient::Gtk4.Orientation = Gtk4.Orientation_VERTICAL
    spacing::Int = 4

    children::Vector{<:AbstractComponent}

    widget::Union{GtkBox, Nothing} = nothing
    parent::Union{GtakComponent, Nothing} = nothing

    const catalyst::Catalyst = Catalyst()
end

HBox(; args...) = Box(; orient = Gtk4.Orientation_HORIZONTAL, args...)
VBox(; args...) = Box(; orient = Gtk4.Orientation_VERTICAL, args...)

function mount!(b::Box, p::GtakComponent)
    b.parent = p
    b.widget = GtkBox(b.orient, b.spacing)
    for child in b.children
        widget = mount!(child, b)
        push!(b.widget, widget)
    end
    return b.widget
end
