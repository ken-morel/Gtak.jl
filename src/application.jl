export Application, application, reload!, configdirs, cachedir

"""
    Base.@kwdef mutable struct Application <: AbstractGtakApplication

The Gtak application comonent, has an internal
store containing it's id, and a vector of windows.
"""
Base.@kwdef mutable struct Application <: AbstractGtakApplication
    id::String
    windows::Vector{AbstractGtakWindow} = []
    app::Union{GtkApplication, Nothing} = nothing
    stores::Dict{Symbol, Atak.AbstractStoreNode} = Dict()
    data::Dict{Symbol, Any} = Dict()
    stylesheet::Union{Stylesheet, Nothing} = nothing
    scheduler::Sched.Scheduler = Sched.Scheduler()
    const _lock = ReentrantLock()
end

Base.schedule(fn::Function, a::Application) = schedule!(fn, a.scheduler)
Base.schedule(a::Application, t::Sched.AbstractPriorityTask) = schedule!(a.scheduler, t)

configdirs(a::Application) = joinpath.(BaseDirs.config(), (a.id,))
cachedir(a::Application) = joinpath(BaseDirs.cache(), a.id)


Base.push!(app::Application, win::AbstractGtakWindow) = @lock app push!(app.windows, win)

"""
    application([init::Function,] id::String)

Create the application, initialize using the
passed function and then mount the application
and return it.
"""
function application(init::Function, id::String; args...)
    app = Application(; id, args...)
    @lock app init(app)
    return app
end

application(id::String; args...) = Application(; id, args...)

"""
    reload!(a::Application; all = false)

Trigger reload of the current page or
all pages of the windows of the application.
"""
reload!(a::Application; all = false) = @lock a foreach(w -> reload!(w; all), a.windows)

"""
    Base.run(app::Application)

Run the gtak application, and mount
it if not already mounted.
"""
function Base.run(app::Application)
    if isnothing(app.app)
        mount!(app)
    end
    if isempty(app.windows)
        @warn "No windows to show in gtak application $(app.id)"
    end
    return run(app.app)
end


"""
    IonicEfus.mount!(app::Application)

Create the application widget, and connect a
signal to mount it's windows when 
`activate` signal received.
"""
function IonicEfus.mount!(app::Application)::GtkApplication
    @lock app begin
        Sched.start!(app.scheduler)
        app.app = GtkApplication(app.id)
        signal_connect(app.app, :activate) do _
            @lock app begin
                isnothing(app.stylesheet) || mount!(app.stylesheet, Gtk4.GdkDisplay())
                mount!.(app.windows, (app,))
            end
        end
        return app.app
    end
end

"""
    IonicEfus.unmount!(app::Application)

Unmount the app windows(See [`IonicEfus.unmount!(::Window)`](@ref))
and destroy the app.
"""
function IonicEfus.unmount!(app::Application)
    @lock app begin
        unmount!.(app.windows)
        isnothing(app.stylesheet) ||unmount!(app.stylesheet)
        if !isnothing(app.app)
            destroy(app.app)
        end
        app.app = nothing

        Sched.stop!(app.scheduler)
    end
    return
end

"""
    spa(fn::Function, id::String = "com.gtak.test")

Run a single page application.

- `fn`: A function receiving the app and window((app, win))
  and which may return a page or pagebuilder.
"""
function spa(fn::Function, id::String = "com.gtak.test")
    return application(id) do app
        window(app) do win
            fn(app, win)
        end
    end
end

public spa
