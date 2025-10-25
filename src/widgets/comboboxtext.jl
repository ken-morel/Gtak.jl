export ComboBoxText

@gtakwidgetcomponent ComboBoxText begin
    items::MayBeReactive{Vector{String}} = String[]
    active::MayBeReactive{Int} = -1 # Gtk default is -1 for no active item
    onchange::Union{Function, Nothing} = nothing

    _signal_id::UInt = 0
    const _activelock = ReentrantLock()
end

function mount!(cbt::ComboBoxText, p::GtakComponent)
    cbt._parent = p
    cbt._widget = GtkComboBoxText()
    _gtakwidgetmountcommon!(cbt, [])

    cbt._signal_id = signal_connect(cbt._widget, "changed") do _
        new_active = Gtk4.active(cbt._widget)
        if !isnothing(cbt.onchange)
            schedule(
                cbt, Sched.CallbackCall(cbt.onchange, Sched.UserInteractive) do
                    @invokelatest cbt.onchange(new_active)
                end
            )
        end
        if cbt.active isa AbstractReactive
            schedule(
                cbt, Sched.ReactantUpdate(cbt.active, Sched.UserInteractive) do
                    trylock(cbt._activelock) && try
                        @ionic cbt.active' = new_active
                    finally
                        unlock(cbt._activelock)
                    end
                end
            )
        end
    end

    return cbt._widget
end

function update!(cbt::ComboBoxText)
    _updates(cbt) do dirt
        if dirt == :items
            Gtk4.remove_all(cbt._widget)
            for item in resolve(Vector{String}, cbt.items)
                Gtk4.push_text(cbt._widget, item)
            end
            # After updating items, we might need to reset the active item
            trylock(cbt._activelock) && try
                Gtk4.active(cbt._widget, resolve(Int, cbt.active))
            finally
                unlock(cbt._activelock)
            end
        elseif dirt == :active
            trylock(cbt._activelock) && try
                Gtk4.active(cbt._widget, resolve(Int, cbt.active))
            finally
                unlock(cbt._activelock)
            end
        end
    end
end

function unmount!(cbt::ComboBoxText)
    if cbt._widget !== nothing && cbt._signal_id != 0
        signal_handler_disconnect(cbt._widget, cbt._signal_id)
        cbt._signal_id = 0
    end
    _gtakunmountwidget!(cbt)
end
