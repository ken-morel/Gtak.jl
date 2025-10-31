export Button

@gtakwidgetcomponent Button  begin
    text::MayBeReactive{<:AbstractString} = ""
    onclick::Union{Function, Nothing} = nothing
    actionname::Union{<:AbstractString, Nothing} = nothing

    _label::Union{GtkLabel, Nothing} = nothing
    _handler_id::UInt = 0

    children::Vector{Component} = []
end


function mount!(b::Button, p::GtakComponent)
    @lock b begin
        b._parent = p
        b._widget = GtkButton()
        _gtakwidgetmountcommon!(b, [])
        if !isnothing(b.actionname)
            b._widget.action_name = b.actionname
        end
        if isempty(b.children)
            b._widget[] = b._label = GtkLabel(resolve(b.text))
        else
            b._widget[] = mount!(b.children[1], b)
            if length(b.children) > 1
                @warn "Label received more than one child"
            end
        end
        b._handler_id = signal_connect(b._widget, :clicked) do _
            if !isnothing(b.onclick)
                schedule(
                    b, Sched.CallbackCall(b.onclick, Sched.UserInteractive) do
                        @invokelatest b.onclick()
                    end
                )
            end
            return
        end
        return b._widget
    end
end


function update!(c::Button)
    return _updates(c) do dirt
        if dirt == :text && !isnothing(c._label)
            Gtk4.markup(c._label, resolve(c.text))
        end
    end
end

function unmount!(b::Button)
    @lock b begin
        if b._widget !== nothing && b._handler_id != 0
            signal_handler_disconnect(b._widget, b._handler_id)
            b._handler_id = 0
        end
        _gtakunmountwidget!(b; widgets = [:_label, :_widget])
        return
    end
end
