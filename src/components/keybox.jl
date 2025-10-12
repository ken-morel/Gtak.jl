export KeyBox

Base.@kwdef mutable struct KeyBox <: GtakComponent
    deps::Vector{<:AbstractReactive}
    builder::Function
    const box = SubParams()

    const innerbox::Box = Box(; box...)
    widget::Union{GtkBox, Nothing} = nothing
    parent::Union{GtakComponent, Nothing} = nothing

    const lock = ReentrantLock()
    const dirty = Set{Symbol}()
    const catalyst = Catalyst()
end

function IonicEfus.mount!(r::KeyBox, p::GtakComponent)
    r.widget = mount!(r.innerbox, r)
    r.parent = p
    callback = (_) -> dirty!(r, :deps)
    for dep in r.deps
        catalyze!(callback, r.catalyst, dep)
    end
    rebuildcontent!(r)
    return r.widget
end

function IonicEfus.update!(r::KeyBox)
    return _updates(r) do key
        if key == :deps
            rebuildcontent!(r)
        end
    end
end

function rebuildcontent!(r::KeyBox)
    empty!(r.widget)
    for comp in r.builder()
        push!(r.widget, mount!(comp, r.innerbox))
    end
    return
end

function IonicEfus.unmount!(r::KeyBox)
    unmount!(r.innerbox)

    denature!(r.catalyst)
    empty!(r._cache)
    empty!(r.dirty)
    r.widget = nothing
    r.parent = nothing
    return
end
