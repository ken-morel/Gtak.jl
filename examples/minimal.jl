include("../../Efus/src/Efus.jl")
include("../src/Gtak.jl")

using .Gtak

function clicked(comp)
  comp[:text] *= ">>"
end

page = efuseval"""
using Gtak

Window title="Hello world" box=vertical
  Label&label text="Welcome to todo app!"
  Box orient=horizontal
    Label text="Enter your todo here"
    Button text="I love A level" onclick=(clicked)
  Box orient=vertical
    
"""Main

if iserror(page)
  display(page)
  exit(1)
end
window = mount!(page)
mainloop(window)
