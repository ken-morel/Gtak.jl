export Switch

@gtakwidgetcomponent Switch  begin
    value::MayBeReactive{Bool} = false
    ontoggle::Union{Function, Nothing} = nothing

    _signal_id::UInt = 0
    const children::Components = []
    const _valuelock = ReentrantLock()
end


function mount!(c::Switch, p::GtakComponent)
    @lock c begin
        c._parent = p
        c._widget = GtkSwitch()
        _gtakwidgetmountcommon!(c, [])
        if !isempty(c.children)
            c._widget[] = mount!(c.children[1])
        end
        c._signal_id = signal_connect(c._widget, "toggled") do _
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
                        trylock(c._valuelock) && try
                            @ionic c.value' = c._widget.active
                        finally
                            unlock(c._valuelock)
                        end
                    end
                )
            end
        end
        return c._widget
    end
end
function update!(c::Switch)
    return _updates(c) do key
        if key == :value
            trylock(c._valuelock) && try
                c._widget.active = resolve(Bool, c.value)
            finally
                unlock(c._valuelock)
            end
        end
    end
end
function unmount!(c::Switch)
    return @lock c begin
        if c._widget !== nothing  && c._signal_id != 0
            signal_handler_disconnect(c._widget, c._signal_id)
        end
        _gtakunmountwidget!(c)
    end
end
