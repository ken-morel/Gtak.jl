export Keyed

@gtakcomponent Keyed <: GtakComponent begin
    deps::Vector{<:AbstractReactive}
    builder::Function
    const box = SubParams()
    _content::Components = Components()

    const innerbox::Box = Box(; box...)
end

function IonicEfus.mount!(r::Keyed, p::GtakComponent)
    r._widget = mount!(r.innerbox, r)
    r._parent = p
    callback = (_) -> dirty!(r, :deps)
    for dep in r.deps
        catalyze!(callback, r._catalyst, dep)
    end
    rebuildcontent!(r)
    return r._widget
end

function IonicEfus.update!(r::Keyed)
    return _updates(r) do key
        if key == :deps
            rebuildcontent!(r)
        end
    end
end

function rebuildcontent!(r::Keyed)
    unmount!.(r._content)
    r._content = @invokelatest r.builder()
    content = []
    for comp in r._content
        push!(content, mount!(comp, r.innerbox))
    end
    empty!(r._widget)
    !isempty(content) && push!(r._widget, content...)
    return
end

function IonicEfus.unmount!(r::Keyed)
    unmount!.(r._content)
    unmount!(r.innerbox)
    denature!(r._catalyst)
    empty!(r._dirty)
    r._widget = nothing
    r._parent = nothing
    return
end
