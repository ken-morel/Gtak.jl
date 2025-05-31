include("../../Efus/src/Efus.jl")
include("../src/Gtak.jl")

using .Gtak
using .Efus
using .Efus: render!, TemplateParameter, CustomTemplate, onrender, onmount, @efus_str, @efuseval_str, iserror, remount!, update!
using Gtk:showall
function checherr(val)
  if iserror(val)
    display(val)
    exit(1)
  end
end
Confirm = CustomTemplate(
  :Confirm,
  TemplateParameter[
    :question! => String,
    :callback => Function,
  ],
  efus"""
    using Gtak

    Box orient=vertical
      Label text=(self[:question])
      Box orient=horizontal
        Button text="Yes" onclick=(accept)
        Button text="No" onclick=(decline)
        Label text=(response)
  """
) do component, namespace
    function respond(response)
      (::Component) -> begin 
        namespace[:response] = "Your response: $response"
        component[:callback](response)
        update!(component)
        rerender!(component)
        remount!(component)
        update!(mount)
      end
    end
    namespace[:accept] = respond(true)
    namespace[:decline] = respond(false)
    namespace[:response] = "Your response: nothing"
end

function responded(id, response)
  println("$id Responded $response")
end


comp = efuseval"""
using Gtak

GtkWindow title="Confirm Example" size=500x400px
  Confirm question="Do you want to continue?" callback=((r) -> responded(1, r))
"""Main

checherr(comp)
mount = mount!(comp)
checherr(mount)

mainloop(mount)
