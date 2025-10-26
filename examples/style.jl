using Gtak

(@main)(_) = Gtak.spa() do _, _
    styles = stylesheet"""
    .label {
      padding: 50px;
      margin: 50px;
      border: 3px blue solid;
    }
    """
    staticpage"""
    Frame box:margin=5
      Label text="Hello world" margin=5
      Button text="CLick me!"
    """styles
end |> run
