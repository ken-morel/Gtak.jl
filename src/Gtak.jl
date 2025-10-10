module Gtak
using Reexport

@reexport using IonicEfus

using FunctionWrappers: FunctionWrapper
@reexport using Gtk4
@reexport using Atak

export GtakComponent, AbstractGtakApplication, AbstractGtakWindow


abstract type AbstractGtakApplication <: Atak.Application end
abstract type GtakComponent <: IonicEfus.Component end
abstract type AbstractGtakWindow <: GtakComponent end


include("./bridge.jl")
include("./page.jl")
include("./router.jl")
include("./window.jl")

include("./application.jl")

#TODO: hello

include("./component.jl")

include("./widgets/widgets.jl")

include("./macros.jl")

end # module Gtak
