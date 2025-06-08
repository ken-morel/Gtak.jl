module Gtak

import Efus
using Efus: evaluateargs!, master, update!, @efuseval_str, mount!, iserror, queryone, remount!, rerender!, format, AbstractMount, TemplateBackend, registertemplatemodule, Component, Template, EOrient, ESize, EInt, EDecimal, EString, registertemplate, ESide, outlet, EReactant
using Gtk4
using Gtk4: GtkWidget

export mainloop, @efuseval_str, mount!, iserror, queryone, remount!, rerender!


function mainloop(win::GtkWindow)
  c = Condition()
  signal_connect(win, :close_request) do widget
    notify(c)
  end
  @async Gtk4.GLib.glib_main()
  wait(c)
end


include("template.jl")
include("templates.jl")
include("window.jl")

function __init__()
  eregister()
end
end


