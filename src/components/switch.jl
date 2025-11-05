export Switched

const _SBCacheRow = Tuple{Any, Components, Vector{<:GtkWidget}}
"""
    Switched(; value, builder, rebuild=false, remount=false, box=SubParams(), kwargs...)

A control flow component that conditionally renders different sets of components based on a reactive `value`.

It is similar to a `match` or `switch` statement, rendering content based on the current state of `value`.

**Fields**
- `value::AbstractReactive`: The reactive value that determines which components to render.
- `builder::Function`: A function that takes the current `value` and returns a `Component` or `Components` to be rendered for that value.
- `rebuild::Bool`: If `true`, the `builder` function is re-executed for the current `value` even if the `value` itself hasn't changed.
- `remount::Bool`: If `true`, components are unmounted and remounted when the `value` changes, even if the rendered components are the same.
- `box::SubParams`: Parameters to pass to the internal `Box` container that holds the rendered content.
"""
@gtakcomponent struct Switched <: GtakComponent
    value::AbstractReactive
    builder::Function
    rebuild::MayBeReactive{Bool} = false
    remount::MayBeReactive{Bool} = false
    const box::SubParams = SubParams()

    const innerbox = Box(; box...)
    const _cache = Set{_SBCacheRow}()
    _content::Components = Components()
end

function IonicEfus.mount!(sb::Switched, p::GtakComponent)
    sb._parent = p
    sb._widget = mount!(sb.innerbox, sb)
    catalyze!(sb._catalyst, sb.value) do _
        dirty!(sb, :value)
    end
    updatecontent!(sb)
    return sb._widget
end

function IonicEfus.update!(sb::Switched)
    return _updates(sb) do key
        if key == :value
            updatecontent!(sb)
        end
    end
end

function updatecontent!(sb::Switched)
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
        remount = true
        components = @invokelatest sb.builder(value)
    end

    if isnothing(widgets) || remount
        widgets = [mount!(c, sb.innerbox) for c in components]
    end

    empty!(sb.innerbox._widget)
    !isempty(widgets) && push!(sb.innerbox._widget, widgets...)
    !found && push!(sb._cache, _SBCacheRow((value, components, widgets)))
    sb._content = components
    return
end
function IonicEfus.unmount!(sb::Switched)
    unmount!(sb.innerbox)
    unmount!.(sb._content)

    denature!(sb._catalyst)
    empty!(sb._cache)
    empty!(sb._dirty)
    sb._widget = nothing
    sb._parent = nothing
    return
end
