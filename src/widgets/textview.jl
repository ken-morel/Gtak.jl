export TextView

@gtakwidgetcomponent TextView begin
    text::MayBeReactive{<:AbstractString} = ""
    editable::Union{MayBeReactive{Bool}, Nothing} = nothing
    monospace::Union{MayBeReactive{Bool}, Nothing} = nothing
    onchange::Union{Function, Nothing} = nothing

    _buffer::Union{GtkTextBuffer, Nothing} = nothing
    _signal_id::UInt = 0
    const _textlock = ReentrantLock()
end

function mount!(tv::TextView, p::GtakComponent)
    @lock tv begin
        tv._parent = p
        tv._widget = GtkTextView()
        tv._buffer = Gtk4.buffer(tv._widget)
        tv._buffer.text = resolve(tv.text)
        _gtakwidgetmountcommon!(tv, [:text])

        if tv.text isa AbstractReactive
            catalyze!(tv._catalyst, tv.text) do r
                trylock(tv._textlock) && try
                    val = getvalue(r)
                    if tv._buffer.text != val
                        tv._buffer.text = val
                    end
                finally
                    unlock(tv._textlock)
                end
            end
        end

        tv._signal_id = signal_connect(tv._buffer, "changed") do _
            current_text = tv._buffer.text
            trylock(tv._textlock) && try
                if tv.text isa AbstractReactive
                    if getvalue(tv.text) != current_text
                        setvalue!(tv.text, current_text)
                    end
                end
            finally
                unlock(tv._textlock)
            end
            if !isnothing(tv.onchange)
                schedule(
                    tv, Sched.CallbackCall(tv.onchange, Sched.Normal) do
                        @invokelatest tv.onchange(current_text)
                    end
                )
            end
        end

        return tv._widget
    end
end

function update!(tv::TextView)
    return _updates(tv) do dirt
        if dirt == :editable && !isnothing(tv.editable)
            tv._widget.editable = resolve(tv.editable)
        elseif dirt == :monospace && !isnothing(tv.monospace)
            tv._widget.monospace = resolve(tv.monospace)
        end
    end
end

function unmount!(tv::TextView)
    @lock tv begin
        if tv._buffer !== nothing && tv._signal_id != 0
            signal_handler_disconnect(tv._buffer, tv._signal_id)
            tv._signal_id = 0
        end
        return _gtakunmountwidget!(tv)
    end
end
