export Switch

const _SBCacheRow = Tuple{Any, Components, Vector{<:GtkWidget}}
@gtakcomponent Switch <: GtakComponent begin
    value::AbstractReactive
    builder::Function
    rebuild::MayBeReactive{Bool} = false
    remount::MayBeReactive{Bool} = false
    const box::SubParams = SubParams()

    const innerbox = Box(; box...)
    const _cache = Set{_SBCacheRow}()
    _content::Components = Components()
end

function IonicEfus.mount!(sb::Switch, p::GtakComponent)
    sb._parent = p
    sb._widget = mount!(sb.innerbox, sb)
    catalyze!(sb._catalyst, sb.value) do _
        dirty!(sb, :value)
    end
    updatecontent!(sb)
    return sb._widget
end

function IonicEfus.update!(sb::Switch)
    return _updates(sb) do key
        if key == :value
            updatecontent!(sb)
        end
    end
end

function updatecontent!(sb::Switch)
    value = getvalue(sb.value)
    rebuild = resolve(Bool, sb.rebuild)
    remount = resolve(Bool, sb.remount)
    components = widgets = nothing
    found = false

    # Detach current widgets from the container
    for child_comp in sb._content
        widget = child_comp._widget
        !isnothing(widget) && Gtk4.remove!(sb.innerbox._widget, widget)
    end

    for row in sb._cache
        if row[1] == value
            found = true
            (_, components, widgets) = row
            break
        end
    end

    if isnothing(components) || rebuild
        remount = true
        components = @invokelatest sb.builder(value)
    end

    if isnothing(widgets) || remount
        widgets = [mount!(c, sb.innerbox) for c in components]
    end

    !isempty(widgets) && push!(sb.innerbox._widget, widgets...)
    !found && push!(sb._cache, _SBCacheRow((value, components, widgets)))
    sb._content = components
    return
end
function IonicEfus.unmount!(sb::Switch)
    unmount!(sb.innerbox)
    unmount!.(sb._content)

    denature!(sb._catalyst)
    empty!(sb._cache)
    empty!(sb._dirty)
    sb._widget = nothing
    sb._parent = nothing
    return
end
