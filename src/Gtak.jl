module Gtak
using Reexport

@reexport using IonicEfus

using FunctionWrappers: FunctionWrapper
using Gtk4


abstract type AbstractGtakApplication end
abstract type GtakComponent <: IonicEfus.Component end
abstract type AbstractGtakWindow <: GtakComponent end


include("./bridge.jl")
include("./scheduler.jl")
include("./page.jl")
include("./router.jl")
include("./window.jl")

include("./application.jl")

#TODO: hello

include("./component.jl")

include("./widgets/widgets.jl")

include("./macros.jl")

end # module Gtak
