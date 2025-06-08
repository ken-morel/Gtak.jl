using Gtak
using Efus: @efus_str, iserror

show = true

page = efuseval"""
using Gtak

GtkWindow title="Hello world" box=vertical
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
  println("created window")
end
