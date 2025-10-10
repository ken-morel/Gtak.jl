include("./src/Gtak.jl")

using .Gtak
#minimal test of functionalities

boxes = ["ama", "bana", "banana"]

application("cm.github.this") do app::Application
    window(app) do _
        hello = Reactant("Hello world")
        onmount!(
            staticpage"""
            Label text=hello
            for box in boxes
              Button text=box onclick =(() -> hello' = hello' * " " * box)
            end
            """
        ) do _
            println("ot page")
        end
    end
end |> run
