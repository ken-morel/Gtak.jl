using Gtak

application("com.test") do app
    window(app) do _
        spin = Reactant(false)
        staticpage"""
        Button text="Toggle spin" onclick=(() -> spin' = !spin')
        Spinner spinning=spin
        Keyed deps=[spin]
          builder()
            Label text=(spin' ? "Spinning!" : "Not spinning")
          end
        """
    end
end |> run
