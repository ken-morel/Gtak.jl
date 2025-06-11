module Application
using Gtk4
using Efus
using Efus: TemplateParameter
using Atak

export runapp, mainloop, init!, Page, PageRoute, PageBuilder
export TemplateParameter, GtakApplication
abstract type AbstractGtakWindow end

include("page.jl")
include("router.jl")
include("window.jl")

mutable struct GtakApplication <: Atak.Application
  toplevel::Union{GtakWindow,Nothing}
  homepage::PageRoute
  namespace::AbstractNamespace
  csspath::Union{String,Nothing}
  css::Union{String,Nothing}
  function GtakApplication(;
    homepage::PageRoute,
    cssfile::String,
    namespace::Union{AbstractNamespace,Nothing}=nothing,
  )
    new(
      nothing,
      homepage,
      isnothing(namespace) ? DictNamespace() : namespace,
      cssfile,
      nothing,
    )
  end
end

function init!(app::GtakApplication)
  if !isnothing(app.csspath) || !isnothing(app.css)
    provider = Gtk4.GtkCssProvider(app.css, app.csspath)
    # Gtk4.add_provider_for_display(Gtk4.GtkDisplay(), provider, Gtk4.GTK_STYLE_PROVIDER_PRIORITY_USER)
  end
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
