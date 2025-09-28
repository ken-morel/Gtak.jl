include("./src/Gtak.jl")

using .Gtak

application("cm.engon.gtak.test") do app
    window(app) do win
        win.title = "First Window"
        page"""
        VBox
          Label text="Hello world"
          Label text="Hello ama"
          HBox
            Label text=|
              "Hello ama"
            Label text=|
              "Horizontal"
        """
    end
end |> run
