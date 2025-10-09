export Window, window, reload!, AbstractGtakWindow


Base.@kwdef mutable struct Window <: AbstractGtakWindow
    app::AbstractGtakApplication
    router::Router = Router(app.bin)
    title::String = "Gtak Window"
    window::Union{GtkWindow, Nothing} = nothing
    catalyst::Catalyst = Catalyst()
end

function reload!(w::Window; all::Bool = false)
    page = reload!(w.router; all)
    return if page isa AbstractPage
        show(w, page)
    end
end

function show(w::Window, p::AbstractPage)
    if isnothing(w.window)
        return
    end
    widgets = mount!(p)
    box = GtkBox(OV)
    push!(box, widgets...)
    return w.window[] = box
end

function window(init::Function, app::AbstractGtakApplication; args...)
    win = Window(; app, args...)
    page = init(win)
    if page isa AbstractPage
        push!(win.router, page)
    elseif page isa PageBuilder
        push!(win.router, page(PageContext(win)))
    end
    push!(app, win)
    return win
end

function IonicEfus.mount!(w::Window, a::AbstractGtakApplication)::GtkApplicationWindow
    w.app = a
    w.window = GtkApplicationWindow(a.app, w.title)
    page = getvalue(w.router.current_page)
    if page isa AbstractPage
        show(w, page)
    end
    catalyze!(w.catalyst, w.router.current_page) do p
        if p isa AbstractPage
            show(w, p)
        end
    end
    present(w.window)
    return w.window
end

function IonicEfus.unmount!(w::Window)
    if !isnothing(w.window)
        destroy(w.window)
    end
    w.window = nothing
    w.app = nothing
    denature!(w.catalyst)
    return
end
