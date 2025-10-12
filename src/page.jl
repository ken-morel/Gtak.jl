export AbstractPage, PageContext, PageBuilder, PageOrBuilder, StaticPage, ReloadablePage
export onmount!, onunmount!


"""
    abstract type AbstractPage <: GtakComponent end

The abstract mother of all gtak page
structures.
"""
abstract type AbstractPage <: GtakComponent end


"""
    mutable struct StaticPage <: AbstractPage

A static page is a page instance which
holds a static or non-reloadable component
tree.

See also [`onmount!`](@ref), [`ReloadablePage`](@ref).
"""
mutable struct StaticPage <: AbstractPage
    content::Components
    onmount::Union{Function, Nothing}
    onunmount::Union{Function, Nothing}
    scheduler::Union{Scheduler, Nothing}
    """
        StaticPage(c::Components)

    Creates a static page with the specified
    component tree.
    """
    StaticPage(c::Components) = new(c, nothing, nothing, nothing)
end

"""
    reload!(s::AbstractPage) = s

A default reload implementation
for gtak pages, it simply does
nothing.
"""
reload!(s::AbstractPage) = s

"""
    const PageBuilderFunction = FunctionWrapper{Components, Tuple{Function}}

A page bulder function accepted by [`ReloadablePage`](@ref)
and more, which returns the components.
The only argument is an onmount which sets a callback
to be called when the component is mounted.
"""
const PageBuilderFunction = FunctionWrapper{Components, Tuple{Function}}

"""
    mutable struct ReloadablePage <: AbstractPage

Holds a component tree whose content can
be rebuilt via the contained builder
via the [`reload!`](@ref) method.
"""
mutable struct ReloadablePage <: AbstractPage
    const builder::PageBuilderFunction
    content::Components
    scheduler::Union{Scheduler, Nothing}
    onmount::Union{Function, Nothing}
    onunmount::Union{Function, Nothing}

    """
        ReloadablePage(builder::Function)
        ReloadablePage(builder::PageBuilderFunction)

    Creates a reloadable page with the specified
    function, the function is a no-argument
    closure which returns a list of components.
    """
    function ReloadablePage(
            builder::PageBuilderFunction,
        )
        page = new(
            builder,
            builder() do cb
                onmount!(page, cb)
            end,
            nothing,
            nothing,
            nothing,
        )
        return page
    end
end
ReloadablePage(
    builder::Function,
) = ReloadablePage(PageBuilderFunction(builder))


"""
    onmount!(fn::Function, p::AbstractPage)::AbstractPage

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
"""
    onunmount!(fn::Function, p::AbstractPage)::AbstractPage

Binds fn which will be called before the coponent is
unmounted.
onunmount! returns the page it was called upon.
"""
onunmount!(fn::Function, p::AbstractPage) = (p.onunmount = fn; p)

"""
    reload!(p::ReloadablePage)

Reload implementation for 
reloadable page which unmounts 
the page(if not already done) then
rebuilds the page.
"""
function reload!(p::ReloadablePage)
    unmount!(p)
    p.content = p.builder() do cb
        onmount!(p, cb)
    end
    return p
end


"""
    const PageBuilder = FunctionWrapper{AbstractPage, Tuple{}}

A page builder creates or builds pages.
"""
const PageBuilder = FunctionWrapper{AbstractPage, Tuple{}}


"""
    IonicEfus.mount!(p::AbstractPage, scheduler::Scheduler)

Mount the specified page, and bind it to
the scheduler for ui updates.
"""
function IonicEfus.mount!(p::AbstractPage, scheduler::Scheduler)
    p.scheduler = scheduler
    contents = mount!.(p.content, (p,))
    unmounter = if !isnothing(p.onmount)
        p.onmount(p)
    end
    if unmounter isa Function
        onunmount!(unmounter, p)
    end
    return contents
end

"Unmount, then remount the passed page"
function IonicEfus.remount!(p::AbstractPage)
    schd = p.scheduler
    unmount!(p)
    return mount!(p, schd)
end

"Unmount the page"
function IonicEfus.unmount!(p::AbstractPage)
    if p.onunmount isa Function
        p.onunmount(p)
    end
    foreach(unmount!, p.content)
    p.scheduler = nothing
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
getscheduler(p::AbstractPage) = p.scheduler
