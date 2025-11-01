export AbstractPage, PageContext, PageBuilder, PageOrBuilder, StaticPage, ReloadablePage
export onmount!, onunmount!
export getstores, getdata

"""
    PageContext

Provides contextual information to a `Page` when it is mounted.

**Fields**
- `application::AbstractGtakApplication`: The parent application.
- `window::AbstractGtakWindow`: The window the page is mounted in.
- `scheduler::Scheduler`: The scheduler for the page.
"""
Base.@kwdef struct PageContext
    application::Union{AbstractGtakApplication, Nothing} = nothing
    window::Union{AbstractGtakWindow, Nothing} = nothing
    scheduler::Union{Scheduler, Nothing} = nothing
end

"""
    push!(ctx::PageContext, page; kwargs...)

Navigate to a new page by pushing it onto the window's router.
"""
Base.push!(ctx::PageContext, p...; args...) = push!(ctx.window.router, p...; args...)

"""
    pop!(ctx::PageContext)

Navigate back to the previous page in the window's router history.
"""
Base.pop!(ctx::PageContext, p...; args...) = pop!(ctx.window.router, p...; args...)

"""
    reload!(ctx::PageContext; kwargs...)

Reload the current window.
"""
reload!(ctx::PageContext; args...) = reload!(ctx.window; args...)

"""
    getdata(ctx::PageContext)

Access the application's `data` dictionary from the page context.
"""
getdata(ctx::PageContext) = ctx.application.data

"""
    getstores(ctx::PageContext)

Access the application's `stores` dictionary from the page context.
"""
getstores(ctx::PageContext) = ctx.application.stores


"""
    abstract type AbstractPage <: GtakComponent end

The abstract supertype for all Gtak pages.
"""
abstract type AbstractPage <: GtakComponent end

getstylesheet(p::AbstractPage) = p.stylesheet


"""
    StaticPage <: AbstractPage

A page whose component tree is built once and is not intended to be reloaded.

**Fields**
- `content::Components`: A vector of the root components for the page.
- `onmount::Function`: A callback executed when the page is mounted.
- `onunmount::Function`: A callback executed when the page is unmounted.
- `stylesheet::Stylesheet`: An optional stylesheet for the page.
"""
Base.@kwdef mutable struct StaticPage <: AbstractPage
    content::Components = Components()
    onmount::Union{Function, Nothing} = nothing
    onunmount::Union{Function, Nothing} = nothing
    context::Union{PageContext, Nothing} = nothing
    stylesheet::Union{Stylesheet, Nothing} = nothing
    const _lock = ReentrantLock()
end
StaticPage(content::Components; kw...) = StaticPage(; content, kw...)

reload!(s::StaticPage) = s

"""
    PageBuilderFunction = FunctionWrapper{Components, Tuple{Function}}

A function that builds the component tree for a `ReloadablePage`.
"""
const PageBuilderFunction = FunctionWrapper{Components, Tuple{Function}}

"""
    ReloadablePage <: AbstractPage

A page whose content can be rebuilt by calling `reload!`. This is essential for hot-reloading during development with `Revise.jl`.

**Fields**
- `builder::PageBuilderFunction`: The function that builds the page's component tree.
- `content::Components`: The current component tree.
- `onmount::Function`: A callback executed when the page is mounted.
- `onunmount::Function`: A callback executed when the page is unmounted.
- `stylesheet::Stylesheet`: An optional stylesheet for the page.
"""
Base.@kwdef mutable struct ReloadablePage <: AbstractPage
    const builder::PageBuilderFunction
    content::Union{Components, Nothing}
    onmount::Union{Function, Nothing}
    onunmount::Union{Function, Nothing}
    context::Union{PageContext, Nothing}
    stylesheet::Union{Stylesheet, Nothing} = nothing
    const _lock = ReentrantLock()

    function ReloadablePage(
            builder::PageBuilderFunction;
            content::Union{Components, Nothing} = nothing,
            onmount::Union{Function, Nothing} = nothing,
            onunmount::Union{Function, Nothing} = nothing,
            stylesheet::Union{Stylesheet, Nothing} = nothing
        )
        page = new(
            builder,
            content,
            onmount,
            onunmount,
            content,
            stylesheet,
            ReentrantLock(),
        )

        if isnothing(page.content)
            page.content = @invokelatest builder((cb::Function) -> onmount!(cb, page))
        end
        return page
    end
end
ReloadablePage(
    builder::Function; kw...
) = ReloadablePage(PageBuilderFunction(builder); kw...)


"""
    onmount!(fn::Function, p::AbstractPage)

Binds a callback `fn` to be executed when the page is mounted. If `fn` returns another function, that function will be bound as the `onunmount` callback.
"""
onmount!(fn::Function, p::AbstractPage) = (p.onmount = fn; p)
onmount!(p::AbstractPage, fn::Function) = onmount!(fn, p)

"""
    onunmount!(fn::Function, p::AbstractPage)

Binds a callback `fn` to be executed just before the page is unmounted.
"""
onunmount!(fn::Function, p::AbstractPage) = (p.onunmount = fn; p)
onunmount!(p::AbstractPage, fn::Function) = onunmount!(fn, p)

"""
    reload!(p::ReloadablePage)

Rebuilds the content of a `ReloadablePage` by calling its builder function again.
"""
function reload!(p::ReloadablePage)
    @lock p begin
        unmount!(p)
        p.content = @invokelatest p.builder(cb -> onmount!(cb, p))
    end
    return p
end


"""
    PageBuilder = FunctionWrapper{AbstractPage, Tuple{}}

A function that builds and returns a page.
"""
const PageBuilder = FunctionWrapper{AbstractPage, Tuple{}}

function IonicEfus.mount!(p::AbstractPage, ctx::Union{PageContext, Nothing} = nothing)
    @lock p begin
        p.context = ctx

        contents = mount!.(p.content, (p,))
        unmounter = if !isnothing(p.onmount)
            @invokelatest p.onmount(p, ctx)
        end
        if unmounter isa Function
            onunmount!(unmounter, p)
        end
        return contents
    end
end

remount!(::AbstractPage) = error("Remounting pages is unsupported")

function unmount!(p::AbstractPage)
    @lock p begin
        if p.onunmount isa Function
            @invokelatest p.onunmount(p)
        end
        foreach(unmount!, p.content)
        p.context = nothing
    end
    return
end

Base.schedule(
    p::AbstractPage, task::Sched.AbstractPriorityTask
) = isnothing(getscheduler(p)) ? nothing : schedule!(getscheduler(p), task)

getscheduler(p::AbstractPage)::Union{Sched.Scheduler, Nothing} = !isnothing(getcontext(p)) ? getcontext(p).scheduler : nothing
getcontext(p::AbstractPage)::Union{PageContext, Nothing} = p.context
