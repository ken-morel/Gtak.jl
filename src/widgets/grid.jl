export Grid

@gtakcomponent Grid <: GtakWidgetComponent begin
    spacing::Union{NTuple{2, Int}, Nothing} = nothing
    homogeneous::Union{NTuple{2, Bool}, Nothing} = nothing

    children::Components = []
end

IonicEfus.params(::Type{Grid}) = Set{Symbol}([:spacing, :homogeneous])

function IonicEfus.mount!(g::Grid, p::GtakComponent)
    g.parent = p
    g.widget = GtkGrid()
    if !isnothing(g.spacing)
        g.widget.row_spacing, g.widget.column_spacing = g.spacing
    end
    if !isnothing(g.homogeneous)
        g.widget.row_homogeneous, g.widget.column_homogeneous = g.homogeneous
    end
    for child in g.children
        lay = getcomponentlayout(child)
        if :pos in keys(lay)
            if lay[:pos] isa Tuple && length(lay[:pos]) == 2
                r, c = lay[:pos]
                g.widget[c, r] = mount!(child, g)
            else
                error("Invalid lay:pos field $(lay[:pos]) of type $(typeof(lay[:pos]))")
            end
        else
            error("Grid child of type $(typeof(child)) has no lay:pos field")
        end
    end
    return g.widget
end

function IonicEfus.update!(g::Grid)
    return _updates(g) do key
        if key == :spacing
            g.widget.row_spacing, g.widget.column_spacing = g.spacing
        elseif key == :homogeneous
            g.widget.row_homogeneous, g.widget.column_homogeneous = g.homogeneous

        end
    end
end

function IonicEfus.unmount!(g::Grid)
    return _gtakunmountwidget!(g)
end
