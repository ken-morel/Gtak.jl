export AbstractGtakApplication, Application, application, reload!

Base.@kwdef mutable struct Application <: AbstractGtakApplication
    id::String
    windows::Vector{AbstractGtakWindow} = []
    app::Union{GtkApplication, Nothing} = nothing
    scheduler::Scheduler = Scheduler()
end

Base.push!(app::Application, win::AbstractGtakWindow) = push!(app.windows, win)

function application(init::Function, id::String; scheduler::Scheduler = Scheduler())
    app = Application(; id, scheduler)
    init(app)
    mount!(app)
    return app
end

reload!(a::Application; all = false) = foreach(w -> reload!(w; all = all), a.windows)

function Base.run(app::Application)
    if isnothing(app.app)
        mount!(app)
    end
    if isempty(app.windows)
        @warn "No windows to run in application"
    end
    start!(app.scheduler)
    return run(app.app)

end


function IonicEfus.mount!(app::Application)::GtkApplication
    app.app = GtkApplication(app.id)
    signal_connect(app.app, :activate) do _
        mount!.(app.windows, (app,))
    end
    return app.app
end

function IonicEfus.unmount!(app::Application)
    unmount!.(app.windows)
    if !isnothing(app.app)
        destroy(app.app)
    end
    return
end

function IonicEfus.remount!(app::Application)
    unmount!(app)
    return mount!(app)
end
