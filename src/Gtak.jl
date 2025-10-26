module Gtak
using Reexport

@reexport using IonicEfus
@reexport using Gtk4
@reexport using Atak
@reexport using BaseDirs: BaseDirs
using StructUtils

import IonicEfus: update!, mount!, unmount!, remount!, getchildren, getparent, dirty!, isdirty, params, getvalue, setvalue!


using FunctionWrappers: FunctionWrapper

using Atak.Sched

export GtakComponent, AbstractGtakApplication, AbstractGtakWindow


abstract type AbstractGtakApplication <: Atak.Application end
abstract type GtakComponent <: IonicEfus.Component end
abstract type AbstractGtakWindow <: GtakComponent end


include("./bridge.jl")
include("./style.jl")
include("./page.jl")
include("./router.jl")
include("./window.jl")

include("./application.jl")

include("./component.jl")

include("./widgets/widgets.jl")

include("./macros.jl")

include("./components/component.jl")

end # module Gtak
