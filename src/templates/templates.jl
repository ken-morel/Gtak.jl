registertemplatemodule(:Gtak)
include("template.jl")


include("window.jl")
include("label.jl")
include("button.jl")
include("box.jl")
include("entry.jl")
include("passwordentry.jl")
include("frame.jl")
include("grid.jl")


function eregister()
  registertemplate(:Gtak, GtakBox)
  registertemplate(:Gtak, GtakButton)
  registertemplate(:Gtak, GtakEntry)
  registertemplate(:Gtak, GtakLabel)
  registertemplate(:Gtak, GtakGtkWindow)
  registertemplate(:Gtak, GtakFrame)
  registertemplate(:Gtak, GtakGrid)
  registertemplate(:Gtak, GtakPasswordEntry)
end
