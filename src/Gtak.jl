module Gtak
using Reexport
using PrecompileTools

@reexport using IonicEfus
@reexport using Gtk4
@reexport using Atak
@reexport using BaseDirs: BaseDirs

using StructUtils

import IonicEfus: update!, mount!, unmount!, remount!, getchildren, getparent, dirty!, isdirty, params, getvalue, setvalue!


using FunctionWrappers: FunctionWrapper

using Atak.Sched

export GtakComponent, AbstractGtakApplication, AbstractGtakWindow

"""
    AbstractGtakApplication <: Atak.Application

Abstract supertype for all Gtak application components.
"""
abstract type AbstractGtakApplication <: Atak.Application end

"""
    GtakComponent <: IonicEfus.Component

Abstract supertype for all Gtak UI components.
"""
abstract type GtakComponent <: IonicEfus.Component end

"""
    AbstractGtakWindow <: GtakComponent

Abstract supertype for all Gtak window components.
"""
abstract type AbstractGtakWindow <: GtakComponent end

"""
    AbstractMenu <: GtakComponent

Abstract supertype for all Gtak menu components.
"""
abstract type AbstractMenu <: GtakComponent end

"""
    AbstractMenuItem <: GtakComponent

Abstract supertype for all Gtak menu item components.
"""
abstract type AbstractMenuItem <: GtakComponent end

export gmain
function gmain(fn::Function)
    done = Threads.Condition()
    err = Ref{Any}(nothing)
    ret = Ref{Any}(nothing)
    Gtk4.g_idle_add() do
        try
            ret[] = fn()
        catch e
            err[] = e
        finally
            @lock done notify(done)
        end
        false
    end
    @lock done wait(done)
    return if err[] != nothing
        throw(err[])
    else
        ret[]
    end
end


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

@setup_workload begin
    @compile_workload begin
        text_reactant = Reactant("")
        items = Reactant([1, 2, 3])
        toggle_reactant = Reactant(false)
        check_reactant = Reactant(false)
        switch_reactant = Reactant(false)
        page = staticpage"""
        VBox spacing=10
            HBox spacing=5
                Label text="Precompiling..."
                Spinner spinning=true
            Separator
            Grid
                Frame lay:pos=(1,1)
                    Button text="Click Me!"
                ToggleButton value=toggle_reactant lay:pos=(1,2)
            CheckButton label="Check" value=check_reactant
            Switch value=switch_reactant
            Entry text=text_reactant
            ProgressBar value=0.5
            For items=items
                builder(item)
                    Label text="Item $(item)"
                end
        """
        @ionic begin
            text_reactant' = text_reactant' * "new text"
            toggle_reactant' = !toggle_reactant'
            check_reactant' = true
            switch_reactant' = true
            push!(items', 4)
        end


        app = application(a -> window(identity, a), "com.gtak.precompile")
    end
end

end # module Gtak
