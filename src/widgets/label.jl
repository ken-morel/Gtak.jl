export Label
Base.@kwdef mutable struct Label <: GtakComponent
    const text::MayBeReactive{String} = ""

    widget::Union{GtkLabel, Nothing} = nothing

    const catalyst::Catalyst = Catalyst()
end

function mount!(l::Label, ::GtakComponent)::GtkLabel
    l.widget = GtkLabel(resolve(String, l.text))
    l.text isa AbstractReactive && catalyze!(l.catalyst, l.text) do r
        set_gtk_property!(l.widget, :label, getvalue(r))
    end
    return l.widget
end

function unmount!(l::Label)
    denature!(l.catalyst)
    if !isnothing(l.widget)
        destroy(l.widget)
    end
    return
end
