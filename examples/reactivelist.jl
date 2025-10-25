using Gtak

const text = Reactant("Hello world")

struct Word
    text::String
end

words = @radical begin
    [Word(word) for word in split(text', " ")]
end

@async 1 + 1


const Page = staticpage"""
ForBox items=(words')::Vector
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
