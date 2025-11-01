export Notebook

"""
    Notebook(; page=0, onswitch=nothing, kwargs...)

A container that displays one of several pages at a time, with tabs to switch between them.

Children of a `Notebook` should specify their tab label using `lay:tab="Tab Name"`.
"""
@gtakwidgetcomponent Notebook begin
    "The index of the currently visible page (0-indexed)."
    page::MayBeReactive{<:Integer} = 0
    "A callback function to execute when the active page changes. Receives the new page index as an argument."
    onswitch::Union{Function, Nothing} = nothing

    const children::Components = []
    _signal_id::UInt = 0
end

function mount!(n::Notebook, p::GtakComponent)
    @lock n begin
        n._parent = p
        n._widget = GtkNotebook()
        _gtakwidgetmountcommon!(n, [])

        for (c, child) in enumerate(n.children)
            lay = getcomponentlayout(child)
            child_widget = mount!(child, n)
            tabname = if !isnothing(lay) && :tab in keys(lay)
                tab_label_widget = GtkLabel(lay[:tab])
            else
                @warn "Notebook child $(typeof(child)) has no lay:pos field"
                "tab#$(c)"
            end
            Gtk4.append_page(n._widget, child_widget, GtkLabel(tabname))
        end

        n._signal_id = signal_connect(n._widget, "switch-page") do _, _, page_num
            if !isnothing(n.onswitch)
                schedule(
                    n, Sched.CallbackCall(n.onswitch, Sched.UserInteractive) do
                        @invokelatest n.onswitch(page_num)
                    end
                )
            end
            if n.page isa AbstractReactive
                schedule(
                    n, Sched.ReactantUpdate(n.page, Sched.Normal) do
                        @ionic n.page' = page_num
                    end
                )
            end
        end

        return n._widget
    end
end

function update!(n::Notebook)
    return _updates(n) do dirt
        if dirt == :page
            Gtk4.page(n._widget, resolve(n.page))
        end
    end
end

function unmount!(n::Notebook)
    @lock n begin
        if n._widget !== nothing && n._signal_id != 0
            signal_handler_disconnect(n._widget, n._signal_id)
            n._signal_id = 0
        end
        _gtakunmountwidget!(n)
    end
    return
end
