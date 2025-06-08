using Gtak: mainloop
using Gtk4
using Efus
using Efus: render!, TemplateParameter, CustomTemplate, onrender, onmount, @efus_str, @efuseval_str, iserror, remount!, query, EReactant, notify!, subscribe!, getvalue

function checkerr(val)
  if iserror(val)
    display(val)
    exit(1)
  end
end

entry = EReactant("John Doe")
subscribe!(entry, nothing) do _, text
  @async begin
    println("  Text changed", text)
    if length(text) > 0 && last(text) == 'b'
      notify!(entry, text * "a")
    end
  end
end


page = efuseval"""
using Gtak

GtkWindow title="Hello world" box=vertical
  Box orient=vertical  # The form
    Box orient=horizontal  # The name
      Label text="Your name:"
      Entry var=(entry)
"""Main

if iserror(page)
  display(page)
  exit(1)
end
window = mount!(page)
mainloop(window)
