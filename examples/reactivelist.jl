using Gtak

const text = Reactant("Hello world")

struct Word
    text::String
end

words = @reactor [Word(word) for word in split(text', " ")]


const Page = staticpage"""
For items=(words')::Vector
  builder(word)
    Label text=(word.text)
  end
Entry text=text # onchange here! not a reactant!
"""

(@main)(_) = application("com.example") do app
    window(app) do _
        Page
    end
end |> run
