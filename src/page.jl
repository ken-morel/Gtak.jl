export AbstractPage, PageContext, PageBuilder, PageOrBuilder, StaticPage, ReloadablePage


abstract type AbstractPage <: GtakComponent end


struct PageContext
    window::AbstractGtakWindow
end


mutable struct StaticPage <: AbstractPage
    component::GtakComponent
    bin::Union{DirtBin, Nothing}
    StaticPage(c::GtakComponent) = new(c, nothing)
end

reload!(s::StaticPage) = s

const PageBuilderFunction = FunctionWrapper{GtakComponent, Tuple{PageContext}}

mutable struct ReloadablePage <: AbstractPage
    const builder::PageBuilderFunction
    const context::PageContext
    component::GtakComponent
    bin::Union{DirtBin, Nothing}

    ReloadablePage(
        builder::Function, context::PageContext,
    ) = ReloadablePage(PageBuilderFunction(builder), context)
    ReloadablePage(
        builder::PageBuilderFunction, context::PageContext,
    ) = new(builder, context, builder(context), nothing)
end

setbin!(p::AbstractPage, bin::Union{DirtBin, Nothing}) = p.bin = bin

function reload!(p::ReloadablePage)
    unmount!(p)
    p.component = p.builder(p.context)
    return p
end


struct PageBuilder
    builder::PageBuilderFunction
    static::Bool
    PageBuilder(
        fn::Function;
        static::Bool = false,
    ) = new(
        PageBuilderFunction(fn),
        static,
    )
end

function (p::PageBuilder)(ctx::PageContext)
    if p.static
        return StaticPage(p.builder(ctx))
    else
        return ReloadablePage(p.builder, ctx)
    end
end

const PageOrBuilder = Union{AbstractPage, PageBuilder}

function mount!(p::AbstractPage; bin::Union{DirtBin, Nothing} = nothing)
    return mount!(p.component, p)
end

function remount!(p::AbstractPage)
    return remount!(p.component, p)
end

function unmount!(p::AbstractPage)
    return unmount!(p.component)
end

function refresh(p::AbstractPage)
    isnothing(p.bin) && return
    dirty = Set{GtakComponent}()
    todo = Set{GtakComponent}([p.component])
    while !isempty(todo)
        comp = pop!(todo)
        isdirty(comp) && push!(dirty, comp)
        children = getchildren(comp)
        if !isnothing(children)
            push!.((todo,), children)
        end
    end
    push!.((p.bin,), dirty)
    return
end
