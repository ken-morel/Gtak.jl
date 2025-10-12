using Gtak

(@main)(_) = Gtak.spa() do _, _
    staticpage"""
    Label text="Hello world"
    """
end |> run
