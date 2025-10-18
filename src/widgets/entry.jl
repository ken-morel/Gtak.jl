export Entry

@gtakwidgetcomponent Entry  begin
    text::MayBeReactive{String} = ""
    placeholder::MayBeReactive{String} = ""
    onchange::Union{Function, Nothing} = nothing

    _changed_handler_id::UInt = 0

    const _textlock = Base.ReentrantLock()
end


function mount!(e::Entry, p::GtakComponent)
    e._parent = p
    e._widget = GtkEntry(text = resolve(String, e.value))
    _gtakwidgetmountcommon!(e, [:text])
    if e.text isa AbstractReactive
        catalyze!(e._catalyst, e.text) do r
            trylock(e._textlock) && try
                val = getvalue(r)
                if e._widget.text != val
                    e._widget.text = val
                end
            finally
                unlock(e._textlock)
            end
        end
    end
    e._changed_handler_id = signal_connect(e._widget, "changed") do _
        trylock(e._textlock) && try
            current_text = e._widget.text
            if e.text isa AbstractReactive
                if getvalue(e.text) != current_text
                    setvalue!(e.text, current_text)
                end
            end

        finally
            unlock(e._textlock)
        end
        if !isnothing(e.onchange)
            schedule(
                e, Sched.CallbackCall(e.onchange, Sched.Normal) do
                    @invokelatest e.onchange(current_text)
                end
            )
        end
    end

    return e._widget
end

function update!(e::Entry)
    return _updates(e) do dirt
        if dirt == :placeholder
            e._widget.placeholder_text = resolve(String, e.placeholder)
        end
    end
end

function unmount!(e::Entry)
    if e._widget !== nothing && e._changed_handler_id !== 0
        signal_handler_disconnect(e._widget, e._changed_handler_id)
        e._changed_handler_id = 0
    end
    _gtakunmountwidget!(e)
    return
end
