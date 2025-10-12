using Gtak
const KEYS = [
    ["1", "2", "3", "+"],
    ["4", "5", "6", "-"],
    ["7", "8", "9", "*"],
    ["(", "0", ")", "/"],
]
const TEXT = Reactant("")

const answer = @radical try
    string(eval(Meta.parse(TEXT')))
catch e
    summary(e)
end

(@main)(_) = Gtak.spa() do _, _
    staticpage"""
    Entry text=TEXT
    Label text=(answer')::String
    Grid spacing=(5, 5)
      for (y, row) in enumerate(KEYS)
        for (x, key) in enumerate(row)
          Button text=key onclick=(() -> TEXT' = TEXT' * key) lay:pos=(y, x)
        end
      end
      Button text="Del" onclick=(
        () -> if !isempty(TEXT')
          TEXT' = TEXT'[1:end-1]
        end
      ) lay:pos=(length(KEYS) + 1, 1:2)
      Button text="Clear" onclick=(() -> TEXT' = "") lay:pos=(length(KEYS) + 1, 3:4)
    """
end |> run
