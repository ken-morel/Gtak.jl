export CheckButton

@gtakwidgetcomponent CheckButton <: GtakWidgetComponent begin
    value::MayBeReactive{Bool} = false
    ontoggle::Union{Function, Nothing} = nothing

    const children::Components = []
    const _valuelock = ReentrantLock()
    _signal_id::UInt = 0
end


function mount!(c::CheckButton, p::GtakComponent)
    c._parent = p
    c._widget = GtkCheckButton()
    c._widget.active = resolve(c.value)
    _gtakwidgetmountcommon!(b, [])
    if !isempty(c.children)
        c._widget[] = mount!(c.children[1])
    end
    signal_connect(c._widget, "toggled") do _
        if !isnothing(c.ontoggle)
            schedule(
                c, Sched.CallbackCall(c.ontoggle, Sched.High) do
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


function update!(c::CheckButton)
    return _updates(c) do dirt
        if dirt == :value
            c.active = resolve(Bool, c.value)
        end
    end
end


function unmount!(c::CheckButton)
    if c._widget !== nothing  && c._signal_id != 0
        signal_handler_disconnect(c._widget, c._signal_id)
        c._signal_id = 0
    end
    return _gtakunmountwidget!(c)
end
