export Notebook

@gtakwidgetcomponent Notebook begin
    page::MayBeReactive{Int} = 0
    on_switch_page::Union{Function, Nothing} = nothing

    const children::Components = []
    _signal_id::UInt = 0
end

function mount!(n::Notebook, p::GtakComponent)
    @lock n begin
        n._parent = p
        n._widget = GtkNotebook()
        _gtakwidgetmountcommon!(n, [])

        for child in n.children
            lay = getcomponentlayout(child)
            tab_label_widget = GtkLabel(get(lay, :tab, ""))
            child_widget = mount!(child, n)
            Gtk4.append_page(n._widget, child_widget, tab_label_widget)
        end

        n._signal_id = signal_connect(n._widget, "switch-page") do _, _, page_num
            if !isnothing(n.on_switch_page)
                schedule(
                    n, Sched.CallbackCall(n.on_switch_page, Sched.UserInteractive) do
                        @invokelatest n.on_switch_page(page_num)
                    end
                )
            end
            if n.page isa AbstractReactive
                @ionic n.page' = page_num
            end
        end

        return n._widget
    end
end

function update!(n::Notebook)
    return _updates(n) do dirt
        if dirt == :page
            Gtk4.page(n._widget, resolve(Int, n.page))
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
