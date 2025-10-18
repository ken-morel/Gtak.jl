export KeyBox

@gtakcomponent KeyBox <: GtakComponent begin
    deps::Vector{<:AbstractReactive}
    builder::Function
    const box = SubParams()

    const innerbox::Box = Box(; box...)
end

function IonicEfus.mount!(r::KeyBox, p::GtakComponent)
    r._widget = mount!(r.innerbox, r)
    r._parent = p
    callback = (_) -> dirty!(r, :deps)
    for dep in r.deps
        catalyze!(callback, r.catalyst, dep)
    end
    rebuildcontent!(r)
    return r._widget
end

function IonicEfus.update!(r::KeyBox)
    return _updates(r) do key
        if key == :deps
            rebuildcontent!(r)
        end
    end
end

function rebuildcontent!(r::KeyBox)
    empty!(r._widget)
    for comp in @invokelatest r.builder()
        push!(r._widget, mount!(comp, r.innerbox))
    end
    return
end

function IonicEfus.unmount!(r::KeyBox)
    unmount!(r.innerbox)

    denature!(r._catalyst)
    empty!(r._cache)
    empty!(r._dirty)
    r._widget = nothing
    r._parent = nothing
    return
end
