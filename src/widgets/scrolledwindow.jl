export ScrolledWindow

export ScrolledWindow

"""
    ScrolledWindow(; kwargs...)

A container that provides scrollbars for its child widget when the child is larger than the allocated space.

It can only have one child.
"""
@gtakwidgetcomponent ScrolledWindow begin
    const children::Components = []
end

function mount!(sw::ScrolledWindow, p::GtakComponent)
    @lock sw begin
        sw._parent = p
        sw._widget = GtkScrolledWindow()
        _gtakwidgetmountcommon!(sw, [])

        if !isempty(sw.children)
            if length(sw.children) > 1
                @warn "ScrolledWindow can only have one child."
            end
            child_widget = mount!(sw.children[1], sw)
            sw._widget.child = child_widget
        end

        return sw._widget
    end
end
