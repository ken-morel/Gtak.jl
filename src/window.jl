export Window, window

Base.@kwdef mutable struct Window <: GtakComponent
    app::Union{AbstractGtakApplication, Nothing} = nothing
    router::Router = Router()
    catalyst::Catalyst = Catalyst()
    title::String = "Gtak Window"
    window::Union{GtkWindow, Nothing} = nothing
end

function window(init::Function, app::AbstractGtakApplication)
    win = Window()
    push!(app, win)
    page = init(win)
    if page isa Page
        push!(win.router, page)
    end
    return win
end

function mount!(w::Window, a::AbstractGtakApplication)::GtkApplicationWindow
    w.app = a
    w.window = GtkApplicationWindow(a.app, w.title)
    page = getvalue(w.router.current_page)
    if page isa Page
        show(w, page)
    end
    catalyze!(w.catalyst, w.router.current_page) do r
        show(w, getvalue(r))
    end
    present(w.window)
    return w.window
end

function show(w::Window, p::Page)
    return w.window[] = mount!(p)
end

function unmount!(w::Window)
    if !isnothing(w.window)
        destroy(w.window)
    end
    denature!(w.catalyst)
    return
end
