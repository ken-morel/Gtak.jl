export Grid

@gtakwidgetcomponent Grid <: GtakWidgetComponent begin
    spacing::Union{NTuple{2, Int}, Nothing} = nothing
    homogeneous::Union{NTuple{2, Bool}, Nothing} = nothing

    children::Components = []
end

params(::Type{Grid}) = Set{Symbol}([:spacing, :homogeneous])

function mount!(g::Grid, p::GtakComponent)
    g.parent = p
    g.widget = GtkGrid()
    push!(g.dirty, :homogeneous, :spacing)
    update!(g)

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

function update!(g::Grid)
    return _updates(g) do key
        if key == :spacing && !isnothing(g.spacing)
            g.widget.row_spacing, g.widget.column_spacing = g.spacing
        elseif key == :homogeneous && !isnothing(g.homogeneous)
            g.widget.row_homogeneous, g.widget.column_homogeneous = g.homogeneous

        end
    end
end
