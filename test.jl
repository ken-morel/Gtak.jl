include("./src/Gtak.jl")

using .Gtak

application("cm.engon.gtak.test") do app
    window(app) do win
        win.title = "First Window"
        page"""
        Label text="Hello world"
        """
    end
end |> run
