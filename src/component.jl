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
                parent::Union{GtakComponent, Nothing} = nothing
                widget::Union{GtkWidget, Nothing} = nothing
                $block
            end
        end
    )
end
