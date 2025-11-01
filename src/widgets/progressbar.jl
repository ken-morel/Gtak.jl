export ProgressBar

export ProgressBar

"""
    ProgressBar(; value=0.0, show_text=nothing, text=nothing, kwargs...)

A widget that displays the progress of an operation.
"""
@gtakwidgetcomponent ProgressBar begin
    "The current value of the progress bar, between 0.0 and 1.0."
    value::MayBeReactive{<:Real} = 0.0
    "Whether to display a text representation of the progress."
    show_text::Union{MayBeReactive{Bool}, Nothing} = nothing
    "The text to display on the progress bar. If `show_text` is `true`, this overrides the default percentage display."
    text::Union{MayBeReactive{String}, Nothing} = nothing
end

function mount!(pb::ProgressBar, p::GtakComponent)
    @lock pb begin
        pb._parent = p
        pb._widget = GtkProgressBar()
        _gtakwidgetmountcommon!(pb, [])
        return pb._widget
    end
end

function update!(pb::ProgressBar)
    return _updates(pb) do dirt
        if dirt == :fraction
            pb._widget.fraction = resolve(pb.fraction)
        elseif dirt == :show_text && !isnothing(pb.show_text)
            pb._widget.show_text = resolve(pb.show_text)
        elseif dirt == :text && !isnothing(pb.text)
            pb._widget.text = resolve(pb.text)
        end
    end
end
