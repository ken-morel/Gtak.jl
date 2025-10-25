function IonicEfus.remount!(c::GtakComponent)
    unmount!(c)
    return mount!(c)
end

macro gtakcomponent(name, block)
    return esc(
        quote
            Base.@kwdef mutable struct $name
                const _dirty = Set{Symbol}()
                const _lock = ReentrantLock()
                const _catalyst = Catalyst()
                _parent::Union{GtakComponent, Nothing} = nothing
                _widget::Union{GtkWidget, Nothing} = nothing
                $(LineNumberNode(__source__.line, __source__.file))
                $block
            end
        end
    )
end
