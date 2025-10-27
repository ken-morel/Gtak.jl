export Video

@gtakwidgetcomponent Video begin
    file::Union{MayBeReactive{String}, Nothing} = nothing
    autoplay::Union{MayBeReactive{Bool}, Nothing} = nothing
    loop::Union{MayBeReactive{Bool}, Nothing} = nothing
end

function mount!(v::GtkVideo, p::GtakComponent)
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
            v._widget.file = Gtk4.Glib.GFile(resolve(String, v.file))
        elseif dirt == :autoplay && !isnothing(v.autoplay)
            v._widget.autoplay = resolve(Bool, v.autoplay)
        elseif dirt == :loop && !isnothing(v.loop)
            v._widget.loop = resolve(Bool, v.loop)
        end
    end
end
