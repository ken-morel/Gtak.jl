export SwitchBox

const _SBCacheRow = Tuple{Any, Components, Vector{<:GtkWidget}}
@gtakcomponent SwitchBox <: GtakComponent begin
    value::AbstractReactive
    builder::Function
    rebuild::Bool = false
    remount::Bool = false
    const box::SubParams = SubParams()

    const innerbox = Box(; box...)
    const _cache = Set{_SBCacheRow}()
end
IonicEfus.params(::Type{SwitchBox}) = Set{Symbol}([:value, :builder, :rebuild, :remount, :box])

function IonicEfus.mount!(sb::SwitchBox, p::GtakComponent)
    sb.parent = p
    sb.widget = mount!(sb.innerbox, sb)
    catalyze!(sb.catalyst, sb.value) do _
        dirty!(sb, :value)
    end
    updatecontent!(sb)
    return sb.widget
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
    components = widgets = nothing
    found = false
    for row in sb._cache
        if row[1] == value
            found = true
            (_, components, widgets) = row
            break
        end
    end
    if isnothing(components) || sb.rebuild
        components = sb.builder(value)
    end
    if isnothing(widgets) || sb.remount
        widgets = [mount!(c, sb.innerbox) for c in components]
    end
    empty!(sb.widget)
    push!(sb.widget, widgets...)
    !found && push!(sb._cache, _SBCacheRow((value, components, widgets)))
    return
end
function IonicEfus.unmount!(sb::SwitchBox)
    unmount!(sb.innerbox)

    denature!(sb.catalyst)
    empty!(sb._cache)
    empty!(sb.dirty)
    sb.widget = nothing
    sb.parent = nothing
    return
end
