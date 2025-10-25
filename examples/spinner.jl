using Gtak

application("com.test") do app
    window(app) do _
        spin = Reactant(false)
        staticpage"""
        Button text="Toggle spin" onclick=(() -> spin' = !spin')
        Spinner spinning=spin
        KeyBox deps=[spin]
          builder()
            if spin'
              Label text="Spinning!"
            else
              Label text="Not spinning"
            end
          end
        """
    end
end |> run
