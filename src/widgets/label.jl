export Label

@gtakwidgetcomponent Label <: GtakWidgetComponent begin
    text::MayBeReactive{String} = ""
    usemarkup::MayBeReactive{Bool} = true
    selectable::Union{MayBeReactive{Bool}, Nothing} = nothing
    justify::Union{MayBeReactive{Gtk4.Justification}, Nothing} = nothing
    wrap::Union{MayBeReactive{Bool}, Nothing} = nothing
    wrapmode::Union{MayBeReactive{Gtk4.WrapMode}, Nothing} = nothing
end


function mount!(l::Label, p::GtakComponent)::GtkLabel
    l._parent = p
    l._widget = GtkLabel(resolve(AbstractString, l.text))
    _gtakwidgetmountcommon!(b, [])
    return l._widget
end

function update!(l::Label)
    return _updates(l) do dirt
        if dirt == :text
            l.widget, resolve(String, l.text)
        elseif dirt == :selectable && !isnothing(l.selectable)
            l._widget.selectable = resolve(Bool, l.selectable)
        elseif dirt == :justify && !isnothing(l.justify)
            l._widget.justify = resolve(Gtk4.Justification, l.justify)
        elseif dirt == :wrap && !isnothing(l.wrap)
            l._widget.wrap = resolve(Bool, l.wrap)
        elseif dirt == :wrapmode && !isnothing(l.wrap_mode)
            l._widget.wrap_mode = resolve(Gtk4.WrapMode, l.wrapmode)
        elseif dirt == :usemarkup
            l._widget.use_markup = resolve(Bool, l.usemarkup)
        end
    end
end
