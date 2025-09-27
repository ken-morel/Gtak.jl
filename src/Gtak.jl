module Gtak
using Efus
using Atak
using FunctionWrappers: FunctionWrapper
using Gtk4

export mount!, remount!, unmount!

abstract type AbstractGtakApplication <: Atak.AbstractApplication end
abstract type GtakComponent <: Efus.AbstractComponent end
abstract type AbstractGtakWindow <: GtakComponent end

include("./page.jl")
include("./router.jl")
include("./window.jl")

include("./application.jl")

include("./component.jl")

include("./widgets/widgets.jl")

include("./macros.jl")

end # module Gtak
