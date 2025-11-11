using Gtak

(@main)(_) =
    Gtak.spa() do _, _
        menu = mount!(Menu("Banana" => () -> println("Hello world")))
        staticpage"""
        VBox
            Label text="Menubutton example"
            MenuButton label="Hello button" menumodel=menu
        """
    end |> run
