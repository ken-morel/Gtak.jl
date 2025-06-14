module Application
using Gtk4
using Efus
using Efus: TemplateParameter
using Atak
using Atak.Store

export runapp, mainloop, init!, Page, PageRoute, PageBuilder
export TemplateParameter, GtakApplication

export datastore, namespace, document, collection
export DataStore, Namespace, Document, Collection
export update!, alter!, set!
export configdir, onmount

abstract type AbstractGtakWindow end

include("page.jl")
include("router.jl")
include("window.jl")

mutable struct GtakApplication <: Atak.Application
  initializer::Function
  id::String
  toplevel::Union{GtakWindow,Nothing}
  homepage::PageRoute
  namespace::AbstractNamespace
  store::Union{DataStore,Nothing}
  data::Dict
  function GtakApplication(
    initializer::Function;
    id::String,
    homepage::PageRoute,
    namespace::Union{AbstractNamespace,Nothing}=nothing,
  )
    new(
      initializer,
      id,
      nothing,
      homepage,
      isnothing(namespace) ? DictNamespace() : namespace,
      nothing,
      Dict(),
    )
  end
end
function init!(app::GtakApplication)
  app.initializer(app)
end
function configdir(app::GtakApplication)::String
  joinpath(homedir(), ".config", app.id) |> mkpath
end
function createwindow(app::GtakApplication)
  window = creategtakwindow()
  home = app.homepage(PageBuildContext(app, window))
  window.router.home = home
  updatecontent!(window)
  app.toplevel = window
end
function mainloop(app::GtakApplication)::Int
  mainloop(app.toplevel.widget)
  0
end
function mainloop(win::GtkWindow)
  Gtk4.show(win)
  c = Condition()
  signal_connect(win, :close_request) do widget
    Gtk4.notify(c)
  end
  @async Gtk4.GLib.glib_main()
  wait(c)
end

function runapp(app::GtakApplication)::Int
  try
    createwindow(app)
    init!(app)
    mainloop(app)
  catch e
    if iserror(e)
      display(e)
      50
    else
      rethrow(e)
    end
  end
end
end
