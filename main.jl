include("../Efus/src/Efus.jl")
include("src/Gtak.jl")

using .Efus: @efuseval_str, mount!, iserror, queryone
using .Gtak

function clicked(comp)
  comp[:text] *= ">>"
end

page = efuseval"""
using Gtak

Window title="Hello world" box=vertical
  Label&label text="A Label"
  Button text="I love A level" onclick=(clicked)
"""Main

if iserror(page)
  display(page)
  exit(1)
end
window = mount!(page)
mainloop(window)



