export Application, application, reload!, configdirs, cachedir

"""
    Application

The top-level container for a Gtak application.

It manages windows, application-wide state, data stores, and the main GTK `GtkApplication` instance.

**Fields**

- `id::String`: The unique application ID (e.g., "com.example.myapp").
- `windows::Vector{AbstractGtakWindow}`: A list of the application's windows.
- `app::Union{GtkApplication, Nothing}`: The underlying `GtkApplication` object.
- `stores::Dict{Symbol, Atak.AbstractStoreNode}`: A dictionary for data persistence, managed by `Atak.jl`.
- `data::Dict{Symbol, Any}`: A dictionary for holding arbitrary application-wide, non-persistent state.
- `stylesheet::Union{Stylesheet, Nothing}`: An optional stylesheet to apply to the application.
- `menubar::Union{Menu, Nothing}`: An optional `Menu` component to be used as the application's menubar.
- `scheduler::Sched.Scheduler`: The task scheduler for the application, provided by `Atak.jl`.
"""
Base.@kwdef mutable struct Application <: AbstractGtakApplication
    id::String
    windows::Vector{AbstractGtakWindow} = []
    app::Union{GtkApplication, Nothing} = nothing
    stores::Dict{Symbol, Atak.AbstractStoreNode} = Dict()
    data::Dict{Symbol, Any} = Dict()
    stylesheet::Union{Stylesheet, Nothing} = nothing
    menubar::Union{Menu, Nothing} = nothing
    scheduler::Sched.Scheduler = Sched.Scheduler()
    const _lock = ReentrantLock()
end

Base.schedule(fn::Function, a::Application) = schedule!(fn, a.scheduler)
Base.schedule(a::Application, t::Sched.AbstractPriorityTask) = schedule!(a.scheduler, t)

"""
    configdirs(a::Application)

Returns the application's configuration directory path.
"""
configdirs(a::Application) = joinpath.(BaseDirs.config(), (a.id,))

"""
    cachedir(a::Application)

Returns the application's cache directory path.
"""
cachedir(a::Application) = joinpath(BaseDirs.cache(), a.id)


Base.push!(app::Application, win::AbstractGtakWindow) = @lock app push!(app.windows, win)

"""
    application(init::Function, id::String; kwargs...)

Create a new `Application`.

This is the main entry point for creating a Gtak application. It creates an `Application` instance, runs the `init` function to allow you to add windows and set up state, and returns the application object, ready to be run with `run()`.

**Arguments**
- `init::Function`: A function that takes the newly created `Application` object as its only argument.
- `id::String`: The unique application ID.
- `kwargs...`: Keyword arguments to be passed to the `Application` constructor (e.g., `stylesheet`, `menubar`).
"""
function application(init::Function, id::String; args...)
    app = Application(; id, args...)
    init(app)
    return app
end

application(id::String; args...) = Application(; id, args...)

"""
    reload!(a::Application; all = false)

Reloads the pages in the application's windows. Useful for development with `Revise.jl`.

- `all=true`: Reloads all pages in the navigation history of each window.
- `all=false` (default): Reloads only the currently visible page in each window.
"""
reload!(a::Application; all = false) = foreach(w -> reload!(w; all), @lock a copy(a.windows))

"""
    Base.run(app::Application)

Starts the GTK event loop and runs the application.
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


function IonicEfus.mount!(app::Application)::GtkApplication
    @lock app begin
        Sched.start!(app.scheduler)
        app.app = GtkApplication(app.id)
        if !isnothing(app.menubar)
            mount!(app.menubar, app.app)
        end
        signal_connect(app.app, :activate) do _
            windows = @lock app begin
                isnothing(app.stylesheet) || mount!(app.stylesheet, Gtk4.GdkDisplay())
                copy(app.windows)
            end
            for window in windows
                mount!(window, app)
            end
        end
        return app.app
    end
end

function IonicEfus.unmount!(app::Application)
    @lock app begin

        unmount!.(app.windows)
        isnothing(app.stylesheet) || unmount!(app.stylesheet)
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

A convenience function to create a Single-Page Application.

It creates an `Application` and a single `Window` in one call.

- `fn`: A function that receives the app and window (`(app, win)`) and returns a `Page` or `PageBuilder`.
"""
function spa(fn::Function, id::String = "com.gtak.test")
    return application(id) do app
        window(app) do win
            fn(app, win)
        end
    end
end

public spa
