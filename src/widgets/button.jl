export Button

@gtakwidgetcomponent Button <: GtakWidgetComponent begin
    text::MayBeReactive{String} = ""
    onclick::Union{Function, Nothing} = nothing
    actionname::Union{String, Nothing} = nothing

    label::Union{GtkLabel, Nothing} = nothing
    _handler_id::UInt = 0

    children::Vector{Component} = []
end


params(::Type{Button}) = Set{Symbol}([:text, :onclick, :actionname])


function mount!(b::Button, p::GtakComponent)
    b.parent = p
    b.widget = GtkButton()
    if !isnothing(b.actionname)
        b.widget.action_name = b.actionname
    end
    if isempty(b.children)
        b.widget[] = b.label = GtkLabel(b.text)
    else
        b.widget[] = mount!(b.children[1], b)
        if length(b.children) > 1
            @warn "Label received more than one child"
        end
    end
    b._handler_id = signal_connect(b.widget, :clicked) do _
        if !isnothing(b.onclick)
            schedule(
                b, Sched.CallbackCall(b.onclick, Sched.UserInteractive) do
                    @invokelatest b.onclick()
                end
            )
        end
        return
    end
    _trackreactiveattributes(b)
    return b.widget
end


function update!(c::Button)
    return _updates(c) do dirt
        if dirt == :text
            if !isnothing(c.label)
                Gtk4.markup(c.label, resolve(String, c.text))
            end
        end
    end
end

function unmount!(b::Button)
    if b.widget !== nothing && b._handler_id != 0
        signal_handler_disconnect(b.widget, b._handler_id)
        b._handler_id = 0
    end
    _gtakunmountwidget!(b; widgets = [:label, :widget])
    return
end
