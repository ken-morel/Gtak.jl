export Window, window, reload!, AbstractGtakWindow


"""
    Window

A top-level window in a Gtak application.

It manages a `Router` to display pages and has its own component lifecycle. Windows are typically created within an `Application`.

**Fields**

- `scheduler::Scheduler`: The task scheduler for this window (often shared with the application).
- `router::Router`: The router that manages the window's page navigation stack.
- `title::String`: The text displayed in the window's title bar.
- `stylesheet::Union{Stylesheet, Nothing}`: An optional stylesheet to apply specifically to this window.
- `window::Union{GtkWindow, Nothing}`: The underlying `GtkApplicationWindow` object.
- `app::Union{AbstractGtakApplication, Nothing}`: The parent application.
- `current_page::Union{AbstractPage, Nothing}`: The currently displayed page.
"""
Base.@kwdef mutable struct Window <: AbstractGtakWindow
    const catalyst = Catalyst()
    const _lock = ReentrantLock()
    _box::Union{GtkBox, Nothing} = nothing
    scheduler::Scheduler = Scheduler()
    router::Router = Router()
    title::String = "Gtak Window"
    stylesheet::Union{Stylesheet, Nothing} = nothing
    window::Union{GtkWindow, Nothing} = nothing
    app::Union{AbstractGtakApplication, Nothing} = nothing
    current_page::Union{AbstractPage, Nothing} = nothing
    context::Union{PageContext, Nothing} = nothing
end

"""
    getcontext(w::Window)

Get the window's `PageContext`.
"""
getcontext(w::Window) = w.context

getapplication(w::Window) = w.app
getscheduler(w::Window) = w.scheduler

"""
    reload!(w::Window; all::Bool = false)

Reloads the current page in the window. If `all=true`, it reloads the entire page history.
"""
function reload!(w::Window; all::Bool = false)
    page = reload!(w.router; all)
    return if page isa AbstractPage
        show(w, page)
    end
end

"""
    Base.show(w::Window, p::Union{AbstractPage, Nothing})

Mounst and displays the given page in the window, unmounting the previous page.
"""
function Base.show(w::Window, p::Union{AbstractPage, Nothing})
    @lock w begin
        isnothing(w.window) && return

        lastpage = w.current_page

        widgets = if p !== w.current_page
            w.current_page = p
            widgets = isnothing(p) ? nothing : mount!(p, getcontext(w))

            if !isnothing(lastpage)
                unmount!(lastpage)
                stylesheet = getstylesheet(lastpage)
                !isnothing(stylesheet) && unmount!(stylesheet)
            end
            widgets
        else
            unmount!(p)
            mount!(p, getcontext(w))
        end
        empty!(w._box) # Just in case

        if !isnothing(p)
            stylesheet = getstylesheet(p)
            isnothing(stylesheet) || mount!(stylesheet, Gtk4.display(w.window))
            isempty(widgets) || push!(w._box, widgets...)
            isempty(widgets) && @warn "Showing empty page in window"
        end
        return widgets
    end
end


"""
    window(init::Function, app::AbstractGtakApplication; kwargs...)

Creates a `Window`, adds it to the application, and runs an initialization function.

The `init` function receives the new window and can return a `Page` or `PageBuilder` to be set as the initial page.
"""
function window(init::Function, app::AbstractGtakApplication; args...)
    win = Window(; app, scheduler = app.scheduler, args...)
    page = init(win)
    if page isa AbstractPage
        push!(win.router, page)
    elseif page isa PageBuilder
        push!(win.router, page())
    end
    push!(app, win)
    return win
end
window(app::AbstractGtakApplication; args...) = Window(; app, args...)

function IonicEfus.mount!(w::Window, app::AbstractGtakApplication)::GtkApplicationWindow
    @lock w begin
        w.context = PageContext(window = w, application = app, scheduler = w.scheduler)
        w.app = app
        w.window = GtkApplicationWindow(w.app.app, w.title)
        w._box = GtkBox(:v; hexpand = true, vexpand = true)
        w.window[] = w._box
        start!(w.scheduler)

        # Set and show the initial page synchronously
        page = getvalue(w.router.current_page)
        w.current_page = page
        if page isa AbstractPage
            show(w, page)
        end

        # Now, set up the reactive listener for subsequent page changes
        catalyze!(w.catalyst, w.router.current_page) do r
            page = getvalue(r)
            if !isnothing(page)
                schedule!(getscheduler(w)) do
                    show(w, page)
                end
            end
        end
        present(w.window)
        return w.window
    end
end

function IonicEfus.unmount!(w::Window)
    @lock w begin
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
    end
    return
end
