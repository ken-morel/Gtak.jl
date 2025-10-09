export Box, HBox, VBox

Base.@kwdef mutable struct Box <: GtakComponent
    orient::Gtk4.Orientation = Gtk4.Orientation_VERTICAL
    spacing::MayBeReactive{Int} = 4
    homogeneous::MayBeReactive{Bool} = false

    const children::Vector{Component} = []

    widget::Union{GtkBox, Nothing} = nothing
    parent::Union{GtakComponent, Nothing} = nothing
    dirty::Set{Symbol} = Set()

    const catalyst::Catalyst = Catalyst()
end

Gtk4.GtkBox(o::Orientation) = GtkBox(o === OV ? :v : :h)

@inline params(::Type{Box}) = [:orient, :spacing]

HBox(; args...) = Box(; orient = Gtk4.Orientation_HORIZONTAL, args...)
VBox(; args...) = Box(; orient = Gtk4.Orientation_VERTICAL, args...)

function IonicEfus.mount!(b::Box, p::GtakComponent)
    b.parent = p
    b.widget = GtkBox(resolve(Gtk4.Orientation, b.orient))
    push!.((b.dirty,), params(Box))
    update!(b)
    for child in b.children
        widget = mount!(child, b)
        push!(b.widget, widget)
    end
    return b.widget
end
function IonicEfus.unmount!(b::Box)
    _gtakunmountwidget!(b)
    return
end

function IonicEfus.update!(b::Box)
    return _updates(b) do dirt
        if dirt == :spacing
            b.widget.spacing = resolve(Int, b.spacing)
        elseif dirt == :homogeneous
            b.widget.homogeneous = resolve(Bool, b.homogeneous)
        end
    end
end
