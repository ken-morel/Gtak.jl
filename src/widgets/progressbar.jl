export ProgressBar

@gtakwidgetcomponent ProgressBar begin
    fraction::MayBeReactive{Float64} = 0.0
    show_text::Union{MayBeReactive{Bool}, Nothing} = nothing
    text::Union{MayBeReactive{String}, Nothing} = nothing
end

function mount!(pb::ProgressBar, p::GtakComponent)
    pb._parent = p
    pb._widget = GtkProgressBar()
    _gtakwidgetmountcommon!(pb, [])
    return pb._widget
end

function update!(pb::ProgressBar)
    _updates(pb) do dirt
        if dirt == :fraction
            pb._widget.fraction = resolve(Float64, pb.fraction)
        elseif dirt == :show_text && !isnothing(pb.show_text)
            pb._widget.show_text = resolve(Bool, pb.show_text)
        elseif dirt == :text && !isnothing(pb.text)
            pb._widget.text = resolve(String, pb.text)
        end
    end
end
