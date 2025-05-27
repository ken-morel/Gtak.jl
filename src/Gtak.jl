module Gtak


using ..Efus
using ..Efus: evaluateargs!, master, update!
using Gtk
using Gtk: GtkWidget


export mainloop



function mainloop(win::GtkWindow)
  if !isinteractive()
    c = Condition()
    signal_connect(win, :destroy) do widget
      notify(c)
    end
    @async Gtk.gtk_main()
    wait(c)
  end
end


include("template.jl")
include("templates.jl")
end
