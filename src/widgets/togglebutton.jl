export ToggleButton

"""
    ToggleButton(; value=false, ontoggle=nothing, kwargs...)

A button that can be toggled between an active and inactive state.
"""
@gtakwidgetcomponent struct ToggleButton
    "The current state of the toggle button (`true` for active, `false` for inactive)."
    value::MayBeReactive{Bool} = false
    "A callback function to execute when the button is toggled. Receives the new boolean state as an argument."
    ontoggle::Union{Function, Nothing} = nothing

    const children::Components = []
    const _valuelock = ReentrantLock()
    _signal_id::UInt = 0
end


function mount!(c::ToggleButton, p::GtakComponent)
    @lock c begin
        c._parent = p
        c._widget = GtkToggleButton()
        _gtakwidgetmountcommon!(c, [])
        if !isempty(c.children)
            c._widget[] = mount!(c.children[1])
        end
        signal_connect(c._widget, "toggled") do _
            if !isnothing(c.ontoggle)
                schedule(
                    c, Sched.CallbackCall(c.ontoggle, Sched.UserInteractive) do
                        @invokelatest c.ontoggle(c._widget.active)
                    end
                )
            end
            if c.value isa AbstractReactive
                schedule(
                    c, Sched.ReactantUpdate(c.value, Sched.UserInteractive) do
                        trylock(c.valuelock) && try
                            @ionic c.value' = c._widget.active
                        finally
                            unlock(c.valuelock)
                        end
                    end
                )
            end
        end
        return c._widget
    end
end
function update!(c::ToggleButton)
    return _updates(c) do key
        if key == :value
            trylock(c._valuelock) && try
                c._widget.active = resolve(c.value)
            finally
                unlock(c._valuelock)
            end
        end
    end
end
function unmount!(c::ToggleButton)
    @lock c begin
        if c._widget !== nothing  && c._signal_id != 0
            signal_handler_disconnect(c._widget, c._signal_id)
        end
        return _gtakunmountwidget!(c)
    end
end
