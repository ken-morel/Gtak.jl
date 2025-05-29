include("../../Efus/src/Efus.jl")
include("../src/Gtak.jl")

using .Gtak

show = true

page = efuseval"""
using Gtak

Window title="Hello world" box=vertical
  if show:
    Label text="Shown finally"
  else:
    Label text="Not shown"
  end
  Button text="downwards button"
"""Main
if iserror(page)
  display(page)
else
  window = mount!(page)
  if iserror(window)
    display(window)
  else
    mainloop(window)
  end
end
