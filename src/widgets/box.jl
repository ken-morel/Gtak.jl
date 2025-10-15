export Box, HBox, VBox

@gtakwidgetcomponent Box <: GtakWidgetComponent begin
    orient::Gtk4.Orientation = Gtk4.Orientation_VERTICAL
    spacing::MayBeReactive{Int} = 4
    homogeneous::MayBeReactive{Bool} = false

    const children::Vector{Component} = []
end

Gtk4.GtkBox(o::Orientation) = GtkBox(o === O_V ? :v : :h)

params(::Type{Box}) = Set{Symbol}([:orient, :spacing, :homogeneous, :expand])

HBox(; args...) = Box(; orient = O_H, args...)
VBox(; args...) = Box(; orient = O_V, args...)

function mount!(b::Box, p::GtakComponent)
    b.parent = p
    b.widget = GtkBox(resolve(Gtk4.Orientation, b.orient))
    push!(b.dirty, params(Box)...)
    update!(b)
    for child in b.children
        widget = mount!(child, b)
        push!(b.widget, widget)
    end
    return b.widget
end

function update!(b::Box)
    return _updates(b) do dirt
        if dirt == :spacing
            b.widget.spacing = resolve(Int, b.spacing)
        elseif dirt == :homogeneous
            b.widget.homogeneous = resolve(Bool, b.homogeneous)
        end
    end
end
