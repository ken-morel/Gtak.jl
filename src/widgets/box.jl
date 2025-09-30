export Box, HBox, VBox

Base.@kwdef mutable struct Box <: GtakComponent
    orient::Gtk4.Orientation = Gtk4.Orientation_VERTICAL
    spacing::MayBeReactive{Int} = 4

    children::Vector{<:AbstractComponent}

    widget::Union{GtkBox, Nothing} = nothing
    parent::Union{GtakComponent, Nothing} = nothing

    const catalyst::Catalyst = Catalyst()
end

params(::Type{Box}) = [:orient, :spacing]

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
function unmount!(b::Box)
    _gtakunmountwidget!(b)
    return
end

function update!(b::Box)
    return _updates(b) do dirt
        if dirt == :spacing
            Gtk4.spacing(b.widget, resolve(Int, b.spacing))
        elseif dirt == :orient
            Gtk4.orientation(b.widget, resolve(Gtk4.Orientation, b.orient))
        end
    end
end
