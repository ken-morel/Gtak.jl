export Scale

@gtakwidgetcomponent Scale begin
    value::MayBeReactive{Float64} = 0.0
    min::MayBeReactive{Float64} = 0.0
    max::MayBeReactive{Float64} = 100.0
    step::MayBeReactive{Float64} = 1.0
    orient::Gtk4.Orientation = O_H
    onchange::Union{Function, Nothing} = nothing

    _signal_id::UInt = 0
    const _valuelock = ReentrantLock()
end

function mount!(s::Scale, p::GtakComponent)
    s._parent = p
    adj = GtkAdjustment(resolve(s.value), resolve(s.min), resolve(s.max), resolve(s.step), 10.0, 0.0)
    s._widget = GtkScale(s.orient == O_H, adj)
    _gtakwidgetmountcommon!(s, [])

    s._signal_id = signal_connect(s._widget, "value-changed") do _
        new_val = Gtk4.value(s._widget)
        if !isnothing(s.onchange)
            schedule(
                s, Sched.CallbackCall(s.onchange, Sched.UserInteractive) do
                    @invokelatest s.onchange(new_val)
                end
            )
        end
        if s.value isa AbstractReactive
            schedule(
                s, Sched.ReactantUpdate(s.value, Sched.UserInteractive) do
                    trylock(s._valuelock) && try
                        @ionic s.value' = new_val
                    finally
                        unlock(s._valuelock)
                    end
                end
            )
        end
    end

    return s._widget
end

function update!(s::Scale)
    return _updates(s) do dirt
        adj = Gtk4.adjustment(s._widget)
        if dirt == :value
            trylock(s._valuelock) && try
                Gtk4.value(adj, resolve(Float64, s.value))
            finally
                unlock(s._valuelock)
            end
        elseif dirt == :min
            Gtk4.lower(adj, resolve(Float64, s.min))
        elseif dirt == :max
            Gtk4.upper(adj, resolve(Float64, s.max))
        elseif dirt == :step
            Gtk4.step_increment(adj, resolve(Float64, s.step))
        end
    end
end

function unmount!(s::Scale)
    if s._widget !== nothing && s._signal_id != 0
        signal_handler_disconnect(s._widget, s._signal_id)
        s._signal_id = 0
    end
    return _gtakunmountwidget!(s)
end
