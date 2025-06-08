registertemplatemodule(:Gtak)
include("templates/window.jl")
include("templates/label.jl")
include("templates/button.jl")
include("templates/box.jl")
include("templates/entry.jl")

function eregister()
  registertemplate(:Gtak, GtakBox)
  registertemplate(:Gtak, GtakButton)
  registertemplate(:Gtak, GtakEntry)
  registertemplate(:Gtak, GtakLabel)
  registertemplate(:Gtak, GtakGtkWindow)
end
