export Button

Base.@kwdef mutable struct Button <: GtakWidgetComponent
    text::MayBeReactive{String} = ""
    onclick::Union{Function, Nothing} = nothing

    widget::Union{GtkButton, Nothing} = nothing
    label::Union{GtkLabel, Nothing} = nothing
    parent::Union{GtakComponent, Nothing} = nothing
    children::Vector{Component} = []

    dirty::Set{Symbol} = Set()

    const catalyst::Catalyst = Catalyst()
end


function IonicEfus.mount!(b::Button, p::GtakComponent)
    b.parent = p
    b.widget = GtkButton()
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
            schedule(b, Atak.UserInteractive) do
                b.onclick()
            end
        end
        return
    end
    _trackreactiveattributes(b)
    return b.widget
end

params(::Type{Button}) = [:text, :onclick]

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
