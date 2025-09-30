module Gtak
using Efus
using Atak
using FunctionWrappers: FunctionWrapper
using Gtk4

import Efus: mount!, remount!, unmount!
export Reactant, AbstractReactive, Catalyst, getvalue, setvalue!

export mount!, remount!, unmount!
export GtakComponent, AbstractGtakWindow, AbstractGtakApplication

export @efus_str

abstract type AbstractGtakApplication <: Atak.AbstractApplication end
abstract type GtakComponent <: Efus.AbstractComponent end
abstract type AbstractGtakWindow <: GtakComponent end


include("./bridge.jl")
include("./bin.jl")
include("./page.jl")
include("./router.jl")
include("./window.jl")

include("./application.jl")

#TODO: hello

include("./component.jl")

include("./widgets/widgets.jl")

include("./macros.jl")

end # module Gtak
