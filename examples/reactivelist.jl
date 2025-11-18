using Gtak

const text = Reactant("Hello world")

@kwdef struct Word
    text::AbstractString
    len::Int
end
function wordinfo(txt::AbstractString)
    return Word(; text = txt, len = length(txt))
end

const Page = staticpage"""
# vector will be diffed
For items=(split(text', " ") .|> wordinfo)::Vector
  builder(word)
    BoxFrame box:margin=10
      Label text=(word.text)
      Label text="$(word.len) letters"
  end
Entry text=text
"""

(@main)(_) = application("com.example") do app
    window(app) do _
        Page
    end
end |> run
