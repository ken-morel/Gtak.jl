export ScrolledWindow

@gtakwidgetcomponent ScrolledWindow begin
    hscrollbar_policy::Union{MayBeReactive{Gtk4.PolicyType}, Nothing} = nothing
    vscrollbar_policy::Union{MayBeReactive{Gtk4.PolicyType}, Nothing} = nothing

    const children::Components = []
end

function mount!(sw::ScrolledWindow, p::GtakComponent)
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

function update!(sw::ScrolledWindow)
    _updates(sw) do dirt
        if dirt == :hscrollbar_policy && !isnothing(sw.hscrollbar_policy)
            Gtk4.hscrollbar_policy(sw._widget, resolve(Gtk4.PolicyType, sw.hscrollbar_policy))
        elseif dirt == :vscrollbar_policy && !isnothing(sw.vscrollbar_policy)
            Gtk4.vscrollbar_policy(sw._widget, resolve(Gtk4.PolicyType, sw.vscrollbar_policy))
        end
    end
end
