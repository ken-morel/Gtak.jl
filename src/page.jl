export AbstractPage, PageContext, PageBuilder, PageOrBuilder, StaticPage, ReloadablePage


abstract type AbstractPage <: GtakComponent end


struct PageContext
    window::AbstractGtakWindow
end


mutable struct StaticPage <: AbstractPage
    content::Components
    scheduler::Union{Scheduler, Nothing}
    StaticPage(c::Components) = new(c, nothing)
end

reload!(s::StaticPage) = s

const PageBuilderFunction = FunctionWrapper{Components, Tuple{PageContext}}

mutable struct ReloadablePage <: AbstractPage
    const builder::PageBuilderFunction
    const context::PageContext
    content::Components
    scheduler::Union{Scheduler, Nothing}

    ReloadablePage(
        builder::Function, context::PageContext,
    ) = ReloadablePage(PageBuilderFunction(builder), context)
    ReloadablePage(
        builder::PageBuilderFunction, context::PageContext,
    ) = new(builder, context, builder(context), nothing)
end

setscheduler!(p::AbstractPage, scheduler::Union{Scheduler, Nothing}) = p.scheduler = scheduler

function reload!(p::ReloadablePage)
    unmount!(p)
    p.content = p.builder(p.context)
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

function IonicEfus.mount!(p::AbstractPage; bin::Union{DirtBin, Nothing} = nothing)
    return mount!.(p.content, (p,))
end

function IonicEfus.remount!(p::AbstractPage)
    return remount!.(p.content, (p,))
end

function IonicEfus.unmount!(p::AbstractPage)
    return unmount!.(p.content)
end


