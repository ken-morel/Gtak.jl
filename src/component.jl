function IonicEfus.remount!(c::GtakComponent)
    unmount!(c)
    return mount!(c)
end

macro gtakcomponent(name, block)
    return esc(
        quote
            Base.@kwdef mutable struct $name
                const dirty = Set{Symbol}()
                const lock = ReentrantLock()
                const catalyst = Catalyst()
                const lay = SubParams()
                _parent::Union{GtakComponent, Nothing} = nothing
                _widget::Union{GtkWidget, Nothing} = nothing
                $(LineNumberNode(__source__.line, __source__.file))
                $block
            end
        end
    )
end
