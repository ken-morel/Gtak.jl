export Entry

"""
    Entry(; text="", placeholder="", onchange=nothing, name=nothing, kwargs...)

A single-line text input field.
"""
@gtakwidgetcomponent struct Entry
    "The current text content of the entry field."
    text::MayBeReactive{<:AbstractString} = ""
    "Placeholder text to display when the entry is empty."
    placeholder::MayBeReactive{<:AbstractString} = ""
    "A callback function to execute when the text in the entry changes. Receives the new text as an argument."
    onchange::Union{Function,Nothing} = nothing
    "The name of the entry widget."
    name::Union{MayBeReactive{<:AbstractString},Nothing} = nothing

    _changed_handler_id::UInt = 0

    const _textsm = Base.Semaphore(1)
end


function mount!(e::Entry, p::GtakComponent)
    @lock e begin
        e._parent = p
        e._widget = GtkEntry(text = resolve(e.text))
        _gtakwidgetmountcommon!(e, [:text])
        if e.text isa AbstractReactive
            catalyze!(e._catalyst, e.text) do _
                dirty!(e, :text)
            end
        end
        e._changed_handler_id = signal_connect(e._widget, "changed") do _
            current_text = e._widget.text

            e.text isa AbstractReactive && schedule(
                e,
                Sched.ReactantUpdate(e.text, Sched.UserInteractive) do
                    Base.acquire(e._textsm) do
                        e.text isa AbstractReactive &&
                            getvalue(e.text) != current_text&&setvalue!(
                                e.text,
                                current_text,
                            )
                    end
                end,
            )

            if !isnothing(e.onchange)
                schedule(e, Sched.CallbackCall(e.onchange, Sched.Normal) do
                    @invokelatest e.onchange(current_text)
                end)
            end
        end

        return e._widget
    end
end

function update!(e::Entry)
    return _updates(e) do dirt
        if dirt == :placeholder
            e._widget.placeholder_text = resolve(e.placeholder)
        elseif dirt == :name && !isnothing(e.name)
            e._widget.name = resolve(e.name)
        elseif dirt == :text
            Base.acquire(e._textsm) do
                val = resolve(e.text)
                if e._widget.text != val
                    e._widget.text = val
                end
            end
        end
    end
end

function unmount!(e::Entry)
    @lock e begin
        if e._widget !== nothing && e._changed_handler_id !== 0
            signal_handler_disconnect(e._widget, e._changed_handler_id)
            e._changed_handler_id = 0
        end
        _gtakunmountwidget!(e)
    end
    return
end
