export CheckButton

@gtakwidgetcomponent CheckButton <: GtakWidgetComponent begin
    value::MayBeReactive{Bool} = false
    ontoggle::Union{Function, Nothing} = nothing

    const children::Components = []
    const valuelock = ReentrantLock()
    _signal_id::UInt = 0
end

params(::Type{CheckButton}) = Set{Symbol}([:value, :ontoggle])

function mount!(c::CheckButton, p::GtakComponent)
    c.parent = p
    c.widget = GtkCheckButton()
    c.widget.active = resolve(c.value)
    if !isempty(c.children)
        c.widget[] = mount!(c.children[1])
    end
    signal_connect(c.widget, "toggled") do _
        if !isnothing(c.ontoggle)
            schedule(
                c, Sched.CallbackCall(c.ontoggle, Sched.High) do
                    @invokelatest c.ontoggle(c.widget.active)
                end
            )
        end
        if c.value isa AbstractReactive
            schedule(
                c, Sched.ReactantUpdate(c.value, Sched.UserInteractive) do
                    trylock(c.valuelock) && try
                        @ionic c.value' = c.widget.active
                    finally
                        unlock(c.valuelock)
                    end
                end
            )
        end
    end
    if c.value isa AbstractReactive
        catalyze!(c.catalyst, c.value) do _
            dirty!(c, :value)
        end
    end
    return c.widget
end
function update!(c::CheckButton)
    return _updates(c) do key
        if key == :value
            trylock(c.valuelock) && try
                c.widget.active = resolve(c.value)
            finally
                unlock(c.valuelock)
            end
        end
    end
end
function unmount!(c::CheckButton)
    if c.widget !== nothing  && c._signal_id != 0
        signal_handler_disconnect(c.widget, c._signal_id)
        c._signal_id = 0
    end
    return _gtakunmountwidget!(c)
end
