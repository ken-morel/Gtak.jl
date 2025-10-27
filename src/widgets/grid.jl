export Grid

@gtakwidgetcomponent Grid  begin
    spacing::Union{NTuple{2, Int}, Int, Nothing} = nothing
    homogeneous::Union{NTuple{2, Bool}, Nothing} = nothing

    children::Components = []
end


function mount!(g::Grid, p::GtakComponent)
    @lock g begin
        g._parent = p
        g._widget = GtkGrid()
        _gtakwidgetmountcommon!(g, [])

        for child in g.children
            lay = getcomponentlayout(child)
            if :pos in keys(lay)
                if lay[:pos] isa Tuple && length(lay[:pos]) == 2
                    r, c = lay[:pos]
                    g._widget[c, r] = mount!(child, g)
                else
                    error("Invalid lay:pos field $(lay[:pos]) of type $(typeof(lay[:pos]))")
                end
            else
                error("Grid child of type $(typeof(child)) has no lay:pos field")
            end
        end
        return g._widget
    end
end

function update!(g::Grid)
    return _updates(g) do key
        if key == :spacing && !isnothing(g.spacing)
            if length(g.spacing) == 1
                g._widget.row_spacing = g._widget.column_spacing = g.spacing
            elseif length(g.spacing) == 2
                g._widget.row_spacing, g._widget.column_spacing = g.spacing
            else
                @warn "Invalid spacing $(g.spacing)"
            end
        elseif key == :homogeneous && !isnothing(g.homogeneous)
            g._widget.row_homogeneous, g._widget.column_homogeneous = g.homogeneous
        end
    end
end
