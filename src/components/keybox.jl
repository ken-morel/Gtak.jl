export KeyBox

@gtakcomponent KeyBox <: GtakComponent begin
    deps::Vector{<:AbstractReactive}
    builder::Function
    const box = SubParams()

    const innerbox::Box = Box(; box...)
end

IonicEfus.params(::Type{KeyBox}) = Set{Symbol}([:deps, :builder, :box])

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
