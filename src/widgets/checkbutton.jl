export CheckButton

"""
    CheckButton(; value=false, ontoggle=nothing, label=nothing, kwargs...)

A button that can be in one of two states: checked or unchecked.
"""
@gtakwidgetcomponent CheckButton  begin
    "The current state of the check button (`true` for checked, `false` for unchecked)."
    value::MayBeReactive{Bool} = false
    "A callback function to execute when the button's state is toggled. Receives the new boolean state as an argument."
    ontoggle::Union{Function, Nothing} = nothing
    "The text label displayed next to the check button."
    label::Union{MayBeReactive{<:AbstractString}, Nothing} = nothing

    const children::Components = []
    const _valuelock = ReentrantLock()
    _signal_id::UInt = 0
end


function mount!(c::CheckButton, p::GtakComponent)
    @lock c begin
        c._parent = p
        c._widget = GtkCheckButton()
        c._widget.active = resolve(c.value)

        _gtakwidgetmountcommon!(c, [])
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
end


function update!(c::CheckButton)
    return _updates(c) do dirt
        if dirt == :value
            c._widget.active = resolve(c.value)
        elseif dirt == :label && !isnothing(c.label)
            c._widget.label = resolve(c.label)
        end
    end
end


function unmount!(c::CheckButton)
    @lock c begin
        if c._widget !== nothing  && c._signal_id != 0
            signal_handler_disconnect(c._widget, c._signal_id)
            c._signal_id = 0
        end
        return _gtakunmountwidget!(c)
    end
end
