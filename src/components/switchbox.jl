export SwitchBox

const _SBCacheRow = Tuple{Any, Components, Vector{<:GtkWidget}}
@gtakcomponent SwitchBox <: GtakComponent begin
    value::AbstractReactive
    builder::Function
    rebuild::MayBeReactive{Bool} = false
    remount::MayBeReactive{Bool} = false
    const box::SubParams = SubParams()

    const innerbox = Box(; box...)
    const _cache = Set{_SBCacheRow}()
end

function IonicEfus.mount!(sb::SwitchBox, p::GtakComponent)
    sb._parent = p
    sb._widget = mount!(sb.innerbox, sb)
    catalyze!(sb._catalyst, sb.value) do _
        dirty!(sb, :value)
    end
    updatecontent!(sb)
    return sb._widget
end

function IonicEfus.update!(sb::SwitchBox)
    return _updates(sb) do key
        if key == :value
            updatecontent!(sb)
        end
    end
end

function updatecontent!(sb::SwitchBox)
    value = getvalue(sb.value)
    rebuild = resolve(Bool, sb.rebuild)
    remount = resolve(Bool, sb.remount)
    components = widgets = nothing
    found = false
    for row in sb._cache
        if row[1] == value
            found = true
            (_, components, widgets) = row
            break
        end
    end
    if isnothing(components) || rebuild
        components = @invokelatest sb.builder(value)
    end
    if isnothing(widgets) || remount
        widgets = [mount!(c, sb.innerbox) for c in components]
    end
    empty!(sb._widget)
    !isempty(widgets) && push!(sb._widget, widgets...)
    !found && push!(sb._cache, _SBCacheRow((value, components, widgets)))
    return
end
function IonicEfus.unmount!(sb::SwitchBox)
    unmount!(sb.innerbox)

    denature!(sb._catalyst)
    empty!(sb._cache)
    empty!(sb._dirty)
    sb._widget = nothing
    sb._parent = nothing
    return
end
