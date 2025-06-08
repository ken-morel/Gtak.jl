using Gtak
using Efus
using Efus: render!, TemplateParameter, CustomTemplate, onrender, onmount, @efus_str, @efuseval_str, iserror, remount!, query, EReactant, notify!

function checkerr(val)
  if iserror(val)
    display(val)
    exit(1)
  end
end

Calculator = CustomTemplate(
  :Calculator,
  TemplateParameter[
    :text=>String=>""
  ],
  efus"""
  using Gtak

  Box orient=vertical
    Label text=(calcocontent)
    Box orient=vertical
      Box orient=horizontal
        Button&key text="1"
        Button&key text="2"
"""
) do calco, namespace
  namespace[:calcocontent] = content = EReactant(calco[:text])
  onrender(calco) do render
    parent = render.render
    isnothing(parent) && return
    for button in query(parent; alias=:key)
      button[:onclick] = (_) -> notify!(content, content.value * button[:text])
      println("set once")
    end
  end
end

comp = efuseval"""
using Gtak

GtkWindow title="Confirm Example" box=vertical
  Calculator text="73"
"""Main
checkerr(comp)

mount = mount!(comp)
checkerr(mount)
mainloop(mount)
