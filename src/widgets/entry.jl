export Entry

Base.@kwdef mutable struct Entry <: GtakWidgetComponent
    text::MayBeReactive{String} = ""
    placeholder::String = ""
    onchange::Union{Function, Nothing} = nothing

    widget::Union{GtkEntry, Nothing} = nothing
    parent::Union{GtakComponent, Nothing} = nothing
    dirty::Set{Symbol} = Set()

    const catalyst::Catalyst = Catalyst()
end

params(::Type{Entry}) = [:text, :placeholder, :onchange]

function IonicEfus.mount!(e::Entry, p::GtakComponent)
    e.parent = p
    e.widget = GtkEntry()

    e.widget.text = resolve(String, e.text)
    e.widget.placeholder_text = resolve(String, e.placeholder)

    if e.text isa AbstractReactive
        catalyze!(e.catalyst, e.text) do _
            dirty!(e, :text, Atak.UserInteractive)
        end
    end
    signal_connect(e.widget, "changed") do _
        current_text = e.widget.text
        if e.text isa AbstractReactive && getvalue(e.text) != current_text
            schedule(e, Priority.UserInteractive) do
                setvalue!(e.text, current_text)
            end
        end
        if !isnothing(e.onchange)
            schedule(e, Atak.Normal) do
                e.onchange(current_text)
            end
        end
    end


    _trackreactiveattributes(e)
    return e.widget
end

function IonicEfus.update!(e::Entry)
    return _updates(e) do dirt
        if dirt == :text
            new_text = resolve(String, e.text)
            if e.widget.text != new_text
                e.widget.text = new_text
            end
        elseif dirt == :placeholder
            e.widget.placeholder_text = e.placeholder
        end
    end
end

function IonicEfus.unmount!(e::Entry)
    _gtakunmountwidget!(e)
    return
end
