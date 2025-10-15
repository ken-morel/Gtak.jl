export Entry

@gtakwidgetcomponent Entry <: GtakWidgetComponent begin
    text::MayBeReactive{String} = ""
    placeholder::String = ""
    onchange::Union{Function, Nothing} = nothing

    _changed_handler_id::UInt = 0

    const textlock = Base.ReentrantLock()
end

params(::Type{Entry}) = Set{Symbol}([:text, :placeholder, :onchange])

function mount!(e::Entry, p::GtakComponent)
    e.parent = p
    e.widget = GtkEntry()

    e.widget.text = resolve(String, e.text)
    e.widget.placeholder_text = resolve(String, e.placeholder)

    if e.text isa AbstractReactive
        catalyze!(e.catalyst, e.text) do r
            trylock(e.textlock) && try
                val = getvalue(r)
                if e.widget.text != val
                    e.widget.text = val
                end
            finally
                unlock(e.textlock)
            end
        end
    end
    e._changed_handler_id = signal_connect(e.widget, "changed") do _
        trylock(e.textlock) && try
            current_text = e.widget.text
            if e.text isa AbstractReactive
                if getvalue(e.text) != current_text
                    setvalue!(e.text, current_text)
                end
            end
            if !isnothing(e.onchange)
                schedule(
                    e, Sched.CallbackCall(e.onchange, Sched.Normal) do
                        @invokelatest e.onchange(current_text)
                    end
                )
            end
        finally
            unlock(e.textlock)
        end
    end

    _trackreactiveattributes(e)
    return e.widget
end

function update!(e::Entry)
    return _updates(e) do dirt
        if dirt == :text
            trylock(e.textlock) && try
                new_text = resolve(String, e.text)
                if e.widget.text != new_text
                    e.widget.text = new_text
                end
            finally
                unlock(e.textlock)
            end
        elseif dirt == :placeholder
            e.widget.placeholder_text = e.placeholder
        end
    end
end

function unmount!(e::Entry)
    if e.widget !== nothing && e._changed_handler_id !== 0
        signal_handler_disconnect(e.widget, e._changed_handler_id)
        e._changed_handler_id = 0
    end
    _gtakunmountwidget!(e)
    return
end
