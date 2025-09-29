export AbstractPage, PageContext, PageBuilder, PageOrBuilder

abstract type AbstractPage <: GtakComponent end


struct PageContext
    window::AbstractGtakWindow
end


struct StaticPage <: AbstractPage
    component::GtakComponent
    function StaticPage(component::GtakComponent)
        return new(component)
    end
end

function reload!(s::StaticPage)
    return s.component
end

struct PageBuilder
    builder::FunctionWrapper{AbstractPage, Tuple{PageContext}}
    static::Bool
    PageBuilder(fn::Function; static::Bool = false) = new(
        FunctionWrapper{AbstractPage, Tuple{PageContext}}(fn), static
    )
end

function (p::PageBuilder)(ctx::PageContext)
    return if p.static
        p.builder(ctx)
    else
        ReloadablePage(p, ctx)
    end
end

const PageOrBuilder = Union{AbstractPage, PageBuilder}


mutable struct ReloadablePage <: AbstractPage
    builder::Function
    component::GtakComponent
    function ReloadablePage(builder::Function)
        return new(builder, builder())
    end
    ReloadablePage(builder::Function, default::GtakComponent)
end

function reload!(p::ReloadablePage)
    return p.component = p.builder(p.context)
end

function mount!(p::AbstractPage)
    return mount!(p.component, p)
end


function remount!(p::AbstractPage)
    return remount!(p.component, p)
end

function unmount!(p::AbstractPage)
    return unmount!(p.component)
end
