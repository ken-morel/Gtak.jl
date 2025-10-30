export AbstractPage, PageContext, PageBuilder, PageOrBuilder, StaticPage, ReloadablePage
export onmount!, onunmount!
export getstores, getdata

Base.@kwdef struct PageContext
    application::Union{AbstractGtakApplication, Nothing} = nothing
    window::Union{AbstractGtakWindow, Nothing} = nothing
    scheduler::Union{Scheduler, Nothing} = nothing
end

Base.push!(ctx::PageContext, p...; args...) = push!(ctx.window.router, p...; args...)
Base.pop!(ctx::PageContext, p...; args...) = pop!(ctx.window.router, p...; args...)
reload!(ctx::PageContext; args...) = reload!(ctx.window; args...)
getdata(ctx::PageContext) = ctx.application.data
getstores(ctx::PageContext) = ctx.application.stores


"""
    abstract type AbstractPage <: GtakComponent end

The abstract mother of all gtak page
structures.
"""
abstract type AbstractPage <: GtakComponent end

getstylesheet(p::AbstractPage) = p.stylesheet


"""
    Base.@kwdef mutable struct StaticPage <: AbstractPage

A static page is a page instance which
holds a static or non-reloadable component
tree.

See also [`onmount!`](@ref), [`ReloadablePage`](@ref).
"""
Base.@kwdef mutable struct StaticPage <: AbstractPage
    content::Components = Components()
    onmount::Union{Function, Nothing} = nothing
    onunmount::Union{Function, Nothing} = nothing
    context::Union{PageContext, Nothing} = nothing
    stylesheet::Union{Stylesheet, Nothing} = nothing
    const _lock = ReentrantLock()
    """
        StaticPage(content::Components;kw...)
        StaticPage(
            content::Components = Components(),
            onmount::Union{Function, Nothing} = nothing,
            onunmount::Union{Function, Nothing} = nothing,
            context::Union{PageContext, Nothing} = nothing,
            stylesheet::Union{Stylesheet, Nothing} = nothing,
        )

    Creates a static page with the specified
    component tree.
    """
end
StaticPage(content::Components; kw...) = StaticPage(; content, kw...)

"""
    reload!(s::AbstractPage) = s

A default reload implementation
for gtak pages, it simply does
nothing.
"""
reload!(s::StaticPage) = s

"""
    const PageBuilderFunction = FunctionWrapper{Components, Tuple{Function}}

A page bulder function accepted by [`ReloadablePage`](@ref)
and more, which returns the components.
The only argument is an onmount which sets a callback
to be called when the component is mounted.
"""
const PageBuilderFunction = FunctionWrapper{Components, Tuple{Function}}

"""
    Base.@kwdef mutable struct ReloadablePage <: AbstractPage

Holds a component tree whose content can
be rebuilt via the contained builder
via the [`reload!`](@ref) method.
"""
Base.@kwdef mutable struct ReloadablePage <: AbstractPage
    const builder::PageBuilderFunction
    content::Union{Components, Nothing}
    onmount::Union{Function, Nothing}
    onunmount::Union{Function, Nothing}
    context::Union{PageContext, Nothing}
    stylesheet::Union{Stylesheet, Nothing} = nothing
    const _lock = ReentrantLock()

    """
        ReloadablePage(builder::Function; kw...)
        ReloadablePage(
            builder::PageBuilderFunction;
            content::Union{Components, Nothing} = nothing,
            onmount::Union{Function, Nothing} = nothing,
            onunmount::Union{Function, Nothing} = nothing,
            stylesheet::Union{Stylesheet, Nothing} = nothing
        )

    Creates a reloadable page with the specified
    function, the function is a no-argument
    closure which returns a list of components.
    """
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
    onmount!(fn::Function, p::AbstractPage)::AbstractPage
    onmount!(p::AbstractPage, fn::Function)

Bind callback `fn` which will be called
after the component is mounted, if the
function returns another function, the 
other function will be called before
the page is unmounted. 
You may also use [`onunmount!`](@ref)
for that.
onmount! returns the page it was called upon.
"""
onmount!(fn::Function, p::AbstractPage) = (p.onmount = fn; p)
onmount!(p::AbstractPage, fn::Function) = onmount!(fn, p)
"""
    onunmount!(fn::Function, p::AbstractPage)::AbstractPage
    onunmount!(p::AbstractPage, fn::Function)

Binds fn which will be called before the coponent is
unmounted.
onunmount! returns the page it was called upon.
"""
onunmount!(fn::Function, p::AbstractPage) = (p.onunmount = fn; p)
onunmount!(p::AbstractPage, fn::Function) = onunmount!(fn, p)

"""
    reload!(p::ReloadablePage)

Reload implementation for 
reloadable page which unmounts 
the page(if not already done) then
rebuilds the page.
"""
function reload!(p::ReloadablePage)
    @lock p begin
        unmount!(p)
        p.content = @invokelatest p.builder(cb -> onmount!(cb, p))
    end
    return p
end


"""
    const PageBuilder = FunctionWrapper{AbstractPage, Tuple{}}

A page builder creates or builds pages.
"""
const PageBuilder = FunctionWrapper{AbstractPage, Tuple{}}

"""
    mount!(p::AbstractPage, scheduler::Scheduler)

Mount the specified page, and bind it to
the scheduler for ui updates.
"""
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

"Unmount, then remount the passed page"
remount!(::AbstractPage) = error("Remounting pages is unsupported")

"Unmount the page"
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

"""
    Base.schedule(fn::Function, p::AbstractPage, pr::Atak.Sched.Priority = Atak.Normal)

Schedule the specified function at the priority
on the pages scheduler.
"""
Base.schedule(
    p::AbstractPage, task::Sched.AbstractPriorityTask
) = isnothing(getscheduler(p)) ? nothing : schedule!(getscheduler(p), task)

"""
    getscheduler(p::AbstractPage)

Returns the pages current scheduler, or nothing.
"""
getscheduler(p::AbstractPage)::Union{Sched.Scheduler, Nothing} = !isnothing(getcontext(p)) ? getcontext(p).scheduler : nothing

"""
    getcontext(p::AbstractPage)

Returns the page's current context.
"""
getcontext(p::AbstractPage)::Union{PageContext, Nothing} = p.context
