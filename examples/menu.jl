using Gtak

(@main)(_) = Gtak.spa() do _, _
    staticpage"""
    VBox
        Label text="Menubutton example"
        MenuButton
    """
end |> run
