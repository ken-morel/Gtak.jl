export Scale

export Scale

"""
    Scale(; value=0.0, min=0.0, max=100.0, step=1.0, orient=Gtk4.Orientation_HORIZONTAL, onchange=nothing, kwargs...)

A slider widget that allows the user to select a value from a range.
"""
@gtakwidgetcomponent Scale begin
    "The current value of the slider."
    value::MayBeReactive{<:Real} = 0.0
    "The minimum value of the range."
    min::MayBeReactive{<:Real} = 0.0
    "The maximum value of the range."
    max::MayBeReactive{<:Real} = 100.0
    "The step increment for the slider."
    step::MayBeReactive{<:Real} = 1.0
    "The orientation of the slider: `Gtk4.Orientation_HORIZONTAL` or `Gtk4.Orientation_VERTICAL`."
    orient::Gtk4.Orientation = O_H
    "A callback function to execute when the slider's value changes. Receives the new value as an argument."
    onchange::Union{Function, Nothing} = nothing

    _signal_id::UInt = 0
    const _valuelock = ReentrantLock()
end

function mount!(s::Scale, p::GtakComponent)
    @lock s begin
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
end

function update!(s::Scale)
    return _updates(s) do dirt
        adj = Gtk4.adjustment(s._widget)
        if dirt == :value
            trylock(s._valuelock) && try
                Gtk4.value(adj, resolve(s.value))
            finally
                unlock(s._valuelock)
            end
        elseif dirt == :min
            Gtk4.lower(adj, resolve(s.min))
        elseif dirt == :max
            Gtk4.upper(adj, resolve(s.max))
        elseif dirt == :step
            Gtk4.step_increment(adj, resolve(s.step))
        end
    end
end

function unmount!(s::Scale)
    @lock s begin
        if s._widget !== nothing && s._signal_id != 0
            signal_handler_disconnect(s._widget, s._signal_id)
            s._signal_id = 0
        end
        _gtakunmountwidget!(s)
    end
    return
end
