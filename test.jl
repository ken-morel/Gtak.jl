include("./src/Gtak.jl")

using .Gtak
#minimal test of functionalities

boxes = ["ama", "bana", "banana"]

application("cm.github.this") do app::Application
    window(app) do win
        staticpage"""
        for box in boxes
          Button text=box
        end
        """
    end
end |> run
