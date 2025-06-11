using Gtak
using Efus: @efuspreeval_str, iserror

page = efuspreeval"""
using Gtak

GtkWindow title="Hello world" box=vertical
"""Main

if iserror(page)
  display(page)
  exit(1)
end
window = mount!(page)
mainloop(window)
