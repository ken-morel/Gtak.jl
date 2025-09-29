export Window, window, getcontext, reload!

Base.@kwdef mutable struct Window <: AbstractGtakWindow
    app::Union{AbstractGtakApplication, Nothing} = nothing
    router::Router = Router()
    catalyst::Catalyst = Catalyst()
    title::String = "Gtak Window"
    window::Union{GtkWindow, Nothing} = nothing
end

getcontext(w::Window) = PageContext(w)

function reload!(w::Window)
    ctx = getcontext(w)
    page = reload!(w.router; all = true)
    if !isnothing(page)
        show(w, page)
    end
    return
end

function window(init::Function, app::AbstractGtakApplication)
    win = Window()
    push!(app, win)
    page = init(win)
    if page isa AbstractPage
        push!(win.router, page)
    elseif page isa PageBuilder
        build = page(getcontext(win))
        push!(win.router, build)
    end
    return win
end

function mount!(w::Window, a::AbstractGtakApplication)::GtkApplicationWindow
    w.app = a
    w.window = GtkApplicationWindow(a.app, w.title)
    page = getvalue(w.router.current_page)
    if page isa AbstractPage
        show(w, page)
    end
    catalyze!(w.catalyst, w.router.current_page) do r
        show(w, getvalue(r))
    end
    present(w.window)
    return w.window
end

function show(w::Window, p::AbstractPage)
    return w.window[] = mount!(p)
end

function unmount!(w::Window)
    if !isnothing(w.window)
        destroy(w.window)
    end
    denature!(w.catalyst)
    return
end
