export AbstractGtakApplication, Application, application, reload!

Base.@kwdef mutable struct Application <: AbstractGtakApplication
    id::String
    windows::Vector{AbstractGtakWindow} = []
    app::Union{GtkApplication, Nothing} = nothing
    bin::DirtBin = DirtBin()
end

Base.push!(app::Application, win::AbstractGtakWindow) = push!(app.windows, win)

function application(init::Function, id::String; bin::DirtBin = DirtBin())
    app = Application(; id, bin)
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
    start!(app.bin)
    return run(app.app)

end


function mount!(app::Application)::GtkApplication
    app.app = GtkApplication(app.id)
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
