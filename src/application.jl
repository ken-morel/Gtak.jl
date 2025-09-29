export AbstractGtakApplication, Application, application

Base.@kwdef mutable struct Application <: AbstractGtakApplication
    id::String
    windows::Vector{Window} = []
    app::Union{GtkApplication, Nothing} = nothing
end

Base.push!(app::Application, win::Window) = push!(app.windows, win)

function application(init::Function, id::String)
    app = Application(; id)
    init(app)
    mount!(app)
    return app
end

reload!(a::Application) = reload!.(a.windows)

function Base.run(app::Application)
    if isnothing(app.app)
        mount!(app)
    end
    run(app.app)
    return 0
end

function mount!(app::Application)::GtkApplication
    println("mounting app")
    app.app = GtkApplication(app.id)
    println("has $(length(app.windows)) windows")
    signal_connect(app.app, :activate) do _
        mount!.(app.windows, (app,))
    end
    return app.app
end

function unmount!(app::Application)
    unmount!.(app.windows)
    if !isnothing(app.app)
        destroy(app.app)
    end
    return
end

function remount!(app::Application)
    unmount!(app)
    return mount!(app)
end
