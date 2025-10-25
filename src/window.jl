export Window, window, reload!, AbstractGtakWindow


"""
    Base.@kwdef mutable struct Window <: AbstractGtakWindow

The gtak window manages a router and displays pages,
windows are all mounted in an application.
They implement efus component lifecycle, so can
me reused an mounted from an app to another.
"""
Base.@kwdef mutable struct Window <: AbstractGtakWindow
    const catalyst::Catalyst = Catalyst()
    _box::Union{GtkBox, Nothing} = nothing
    scheduler::Scheduler = Scheduler()
    router::Router = Router()
    title::String = "Gtak Window"
    window::Union{GtkWindow, Nothing} = nothing
    app::Union{AbstractGtakApplication, Nothing} = nothing
    current_page::Union{AbstractPage, Nothing} = nothing
    context::Union{PageContext, Nothing} = nothing
end

"""
    getcontext(::Window)

Get the window's [`PageContext`](@ref).
"""
getcontext(w::Window) = w.context

getapplication(w::Window) = w.app
getscheduler(w::Window) = w.scheduler

"""
    reload!(w::Window; all::Bool = false)

Reload the current page in the window, 
if `all`, then reloads also the history stack
and redisplays the first page.
"""
function reload!(w::Window; all::Bool = false)
    page = reload!(w.router; all)
    return if page isa AbstractPage
        show(w, page)
    end
end

"""
    Base.show(w::Window, p::AbstractPage)

Mount and display the page in the window,
unmounting previously shown page.
"""
function Base.show(w::Window, p::AbstractPage)
    if isnothing(w.window)
        return
    end
    if !isnothing(w.current_page)
        unmount!(w.current_page)
    end
    w.current_page = p
    widgets = mount!(p, getcontext(w))
    empty!(w._box)
    !isempty(widgets)  && push!(w._box, widgets...)
    return widgets
end

"""
    window(init::Function, app::AbstractGtakApplication; args...)

Helper which creates the window, calls the init on it and
adds the window to the app, if the app was already
mounted the new window will not be mounted and has
to manually be mounted in the init!, the init
can return a page which will be shown on the window.
"""
function window(init::Function, app::AbstractGtakApplication; args...)
    win = Window(; app, args...)
    page = init(win)
    if page isa AbstractPage
        push!(win.router, page)
    elseif page isa PageBuilder
        push!(win.router, page())
    end
    push!(app, win)
    return win
end

"""
    IonicEfus.mount!(w::Window, app::AbstractGtakApplication)::GtkApplicationWindow

Mounts the window in the application returning
the underlying gtk widget.
"""
function IonicEfus.mount!(w::Window, app::AbstractGtakApplication)::GtkApplicationWindow
    w.context = PageContext(window = w, application = app, scheduler = w.scheduler)
    w.app = app
    w.window = GtkApplicationWindow(w.app.app, w.title)
    w._box = GtkBox(:v)
    w.window[] = w._box
    start!(w.scheduler)
    page = getvalue(w.router.current_page)
    if page isa AbstractPage
        show(w, page)
    end
    catalyze!(w.catalyst, w.router.current_page) do r
        page = getvalue(r)
        if !isnothing(page)
            schedule!(getscheduler(w), Sched.High) do
                show(w, page)
            end
        end
    end
    present(w.window)
    return w.window
end

"""
    IonicEfus.unmount!(w::Window)

Unmount the window.
"""
function IonicEfus.unmount!(w::Window)
    if !isnothing(w.currentpage)
        unmount!(w.current_page)
        w.current_page = nothing
    end
    if !isnothing(w.window)
        destroy(w.window)
    end
    stop!(w.scheduler)
    w.window = nothing
    w.app = nothing
    w._box = nothing
    w.context = nothing
    denature!(w.catalyst)
    return
end
