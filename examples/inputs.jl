include("../../Efus/src/Efus.jl")
include("../src/Gtak.jl")

using .Gtak
using .Efus
using .Efus: render!, TemplateParameter, CustomTemplate, onrender, onmount, @efus_str, @efuseval_str, iserror, remount!, query, EReactant, notify!

function checkerr(val)
  if iserror(val)
    display(val)
    exit(1)
  end
end

#TODO
