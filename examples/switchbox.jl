using Gtak

const ITEMS = Reactant(["Banana", "Plantain", "Orange"])
const ITEM = Reactant("Banana")
const text = Reactant("")

function additem()
    @ionic begin
        ITEMS' = push!(ITEMS', text')
        text' = ""
    end
    return
end

(@main)(_) = application("com.test") do app
    window(app) do _
        staticpage"""
        Label text=("Notebook of $(ITEM')s")::String
        Frame
          ForBox items=ITEMS box:orient=OH
            builder(item)
              Button text=item onclick=(() -> ITEM' = item)
            end
          Separator
          SwitchBox value=ITEM
            builder(item)
              Label text="This will be built only once"
              (println("Building for $item");)
              Label text="Current item: $item"
            end
        HBox
          Entry onchange=(val -> text' = val)
          Button text="Add tab" onclick=additem
        """
    end
end |> run
