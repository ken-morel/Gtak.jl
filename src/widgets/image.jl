export Image

@gtakwidgetcomponent Image begin
    file::Union{MayBeReactive{String}, Nothing} = nothing
    icon_name::Union{MayBeReactive{String}, Nothing} = nothing
    pixel_size::Union{MayBeReactive{Int}, Nothing} = nothing
end

function mount!(i::Image, p::GtakComponent)
    @lock i begin
        i._parent = p
        i._widget = GtkImage()
        _gtakwidgetmountcommon!(i, [])
        return i._widget
    end
end

function update!(i::Image)
    return _updates(i) do dirt
        if dirt == :file && !isnothing(i.file)
            i._widget.file = resolve(String, i.file)
        elseif dirt == :icon_name && !isnothing(i.icon_name)
            i._widget.icon_name = resolve(String, i.icon_name)
        elseif dirt == :pixel_size && !isnothing(i.pixel_size)
            i._widget.pixel_size = resolve(Int, i.pixel_size)
        end
    end
end
