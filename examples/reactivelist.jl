using Gtak

const text = Reactant("Hello world")
const items = Reactant(["Hello"])

@radical begin
    content = text'
    items' = split(content, " ")
end

const Page = staticpage"""
ForBox items=(items')::Vector{String}
  builder(item)
    Label text="Hello $item"
  end
Entry text=text # onchange here! not a reactant!
"""

(@main)(_) = application("com.example") do app
    window(app) do _
        Page
    end
end |> run
