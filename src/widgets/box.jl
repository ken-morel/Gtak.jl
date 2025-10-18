export Box, HBox, VBox

@gtakwidgetcomponent Box  begin
    orient::Gtk4.Orientation = Gtk4.Orientation_VERTICAL
    spacing::Union{MayBeReactive{Int}, Nothing} = nothing
    homogeneous::Union{MayBeReactive{Bool}, Nothing} = nothing

    const children::Vector{Component} = []
end

Gtk4.GtkBox(o::Orientation) = GtkBox(o === O_V ? :v : :h)


HBox(; args...) = Box(; orient = O_H, args...)
VBox(; args...) = Box(; orient = O_V, args...)

function mount!(b::Box, p::GtakComponent)
    b._parent = p
    b._widget = GtkBox(b.orient)
    _gtakwidgetmountcommon!(b, [])
    for child in b.children
        widget = mount!(child, b)
        push!(b._widget, widget)
    end
    return b._widget
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
