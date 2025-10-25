function HomeContent(onmount::Function)
    username = Reactant("")
    user = nothing
    colentry = Reactant("")
    todos = Reactant(Todo[])

    onmount() do _, ctx
        user = getdata(ctx)[:user]
        @ionic begin
            username' = getdata(ctx)[:user].name
            todos' = getstores(ctx)[:todos]'
        end
        @radical begin  # subscribes after the preceeding assigns
            getstores(ctx)[:todos]' = todos'
        end
    end
    return efus"""
    Label text=(
      "<big>Hello $(username')</big>, here are your collections"
    )::String margin=10
    Separator
    VBox margin=20
      ForBox items=todos box:spacing=10
        builder(todo)
            Frame box:orient=O_H
              Label text=(todo.text) margin=15
              Separator margin=(0,15,0,0)
              Grid spacing=(1, 10) margin=10
                Label text="<b>ID:</b>"    lay:pos=(1,1)
                Label text="$(todo.id)"    lay:pos=(1,2)
                Label text="<b>Owner:</b>"  lay:pos=(2,1)
                Label text="$(todo.userid)"  lay:pos=(2,2)
              HBox expand=true
              Button text="Open" expand=(true, false) margin=10
        end
    HBox expand=(false, true)
      Entry text=colentry
      Button text="Add" onclick=(() -> begin
        push!(todos', Todo(;userid=user.id, text=colentry'))
        IonicEfus.notify(todos)
        colentry' = ""
      end)
    """
end

const Home = ReloadablePage() do onmount
    println("Constructing page takes")
    @time HomeContent(onmount)
end
