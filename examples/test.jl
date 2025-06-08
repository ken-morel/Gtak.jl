using Gtak
using Efus
using Efus: render!, TemplateParameter, CustomTemplate, onrender, onmount, @efus_str, @efuseval_str, iserror, remount!
function checkerr(val)
  if iserror(val)
    display(val)
    exit(1)
  end
end
comp = efuseval"""
using Gtak

GtkWindow title="Confirm Example" box=vertical
  Label text="This is a test of the Gtak library with Efus."
"""Main
checkerr(comp)

mount = mount!(comp)
checkerr(mount)
mainloop(mount)
