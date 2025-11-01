export Label

"""
    Label(; text="", usemarkup=true, selectable=nothing, justify=nothing, wrap=nothing, wrapmode=nothing, kwargs...)

A widget that displays a block of text.
"""
@gtakwidgetcomponent Label begin
    "The text to display. Supports Pango markup if `usemarkup` is `true`."
    text::MayBeReactive{<:AbstractString} = ""
    "Whether to parse Pango markup in the `text`."
    usemarkup::MayBeReactive{Bool} = true
    "Whether the user can select the text."
    selectable::Union{MayBeReactive{Bool}, Nothing} = nothing
    "The justification of the text."
    justify::Union{MayBeReactive{Gtk4.Justification}, Nothing} = nothing
    "Whether to wrap the text if it exceeds the widget's width."
    wrap::Union{MayBeReactive{Bool}, Nothing} = nothing
    "The wrapping mode to use."
    wrapmode::Union{MayBeReactive{Gtk4.WrapMode}, Nothing} = nothing
end


function mount!(l::Label, p::GtakComponent)::GtkLabel
    @lock l begin
        l._parent = p
        l._widget = GtkLabel(resolve(AbstractString, l.text))::GtkLabel
        _gtakwidgetmountcommon!(l, [])
        return l._widget
    end
end

function update!(l::Label)
    return _updates(l) do dirt
        if dirt == :text
            l._widget.label = resolve(l.text)
        elseif dirt == :selectable && !isnothing(l.selectable)
            l._widget.selectable = resolve(l.selectable)
        elseif dirt == :justify && !isnothing(l.justify)
            l._widget.justify = resolve(Gtk4.Justification, l.justify)
        elseif dirt == :wrap && !isnothing(l.wrap)
            l._widget.wrap = resolve(l.wrap)
        elseif dirt == :wrapmode && !isnothing(l.wrapmode)
            l._widget.wrap_mode = resolve(Gtk4.WrapMode, l.wrapmode)
        elseif dirt == :usemarkup
            l._widget.use_markup = resolve(l.usemarkup)
        end
    end
end
