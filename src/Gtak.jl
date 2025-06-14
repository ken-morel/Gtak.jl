module Gtak

using Efus
using Efus: AbstractMount, TemplateBackend, TemplateParameter
using Gtk4
using Gtk4: GtkWidget
using Atak

include("templates/templates.jl")

include("Application/Application.jl")

function __init__()
  eregister()
end
end


