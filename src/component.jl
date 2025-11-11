function Efus.remount!(c::GtakComponent)
    p = getparent(c)
    unmount!(c)
    return mount!(c, p)
end

macro gtakcomponent(def)
    @assert def.head == :struct
    base = quote
        const _dirty::Set{Symbol} = Set{Symbol}()
        const _lock::ReentrantLock = ReentrantLock()
        const _catalyst::Catalyst = Catalyst()
        _parent::Union{Component, Nothing} = nothing
        _widget::Union{Gtk4.GLib.GObject, Nothing} = nothing
    end

    def.args[1] = true
    append!(def.args[3].args, base.args[2:end])

    return esc(Expr(:macrocall, Symbol("@kwarg"), LineNumberNode(__source__.line, __source__.file), def))
end
