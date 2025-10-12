export Box, HBox, VBox

@gtakcomponent Box <: GtakWidgetComponent begin
    orient::Gtk4.Orientation = Gtk4.Orientation_VERTICAL
    spacing::MayBeReactive{Int} = 4
    homogeneous::MayBeReactive{Bool} = false
    expand::Symbol = :none

    const children::Vector{Component} = []
end

Gtk4.GtkBox(o::Orientation) = GtkBox(o === OV ? :v : :h)

IonicEfus.params(::Type{Box}) = Set{Symbol}([:orient, :spacing, :homogeneous, :expand])

HBox(; args...) = Box(; orient = Gtk4.Orientation_HORIZONTAL, args...)
VBox(; args...) = Box(; orient = Gtk4.Orientation_VERTICAL, args...)

function IonicEfus.mount!(b::Box, p::GtakComponent)
    b.parent = p
    b.widget = GtkBox(resolve(Gtk4.Orientation, b.orient))
    push!.((b.dirty,), params(Box))
    IonicEfus.update!(b)
    setexpand!(b.widget, b.expand)
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
        elseif dirt == :expand
            setexpand!(b.widget, b.expand)
        end
    end
end
function setexpand!(b::GtkBox, v::Symbol)
    b.vexpand = v == :both || v == :h
    b.hexpand = v == :both || v == :v
    return
end
