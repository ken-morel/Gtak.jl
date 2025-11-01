export Video

"""
    Video(; file=nothing, autoplay=nothing, loop=nothing, kwargs...)

A widget that displays a video from a file.
"""
@gtakwidgetcomponent Video begin
    "The path to a video file to display."
    file::Union{MayBeReactive{<:AbstractString}, Nothing} = nothing
    "Whether the video should start playing automatically."
    autoplay::Union{MayBeReactive{Bool}, Nothing} = nothing
    "Whether the video should loop when it reaches the end."
    loop::Union{MayBeReactive{Bool}, Nothing} = nothing
end

function mount!(v::Video, p::GtakComponent)
    @lock v begin
        v._parent = p
        v._widget = GtkVideo()
        _gtakwidgetmountcommon!(v, [])
        return v._widget
    end
end

function update!(v::Video)
    return _updates(v) do dirt
        if dirt == :file && !isnothing(v.file)
            v._widget.file = Gtk4.Glib.GFile(resolve(v.file))
        elseif dirt == :autoplay && !isnothing(v.autoplay)
            v._widget.autoplay = resolve(Bool, v.autoplay)
        elseif dirt == :loop && !isnothing(v.loop)
            v._widget.loop = resolve(Bool, v.loop)
        end
    end
end
