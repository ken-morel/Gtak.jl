export Button

@gtakcomponent Button <: GtakWidgetComponent begin
    text::MayBeReactive{String} = ""
    onclick::Union{Function, Nothing} = nothing
    const actionname::Union{String, Nothing} = nothing

    label::Union{GtkLabel, Nothing} = nothing

    children::Vector{Component} = []
end


function IonicEfus.mount!(b::Button, p::GtakComponent)
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
    signal_connect(b.widget, :clicked) do _
        if !isnothing(b.onclick)
            schedule(
                b, Sched.CallbackCall(b.onclick, Sched.UserInteractive) do
                    b.onclick()
                end
            )
        end
        return
    end
    _trackreactiveattributes(b)
    return b.widget
end

IonicEfus.params(::Type{Button}) = Set{Symbol}([:text, :onclick])

function IonicEfus.update!(c::Button)
    return _updates(c) do dirt
        if dirt == :text
            if !isnothing(c.label)
                Gtk4.markup(c.label, resolve(String, c.text))
            end
        end
    end
end

function IonicEfus.unmount!(b::Button)
    _gtakunmountwidget!(b; widgets = [:label, :widget])
    return
end
