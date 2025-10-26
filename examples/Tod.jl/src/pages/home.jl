function HomeContent(onmount::Function)
    username = Reactant("")
    user = nothing

    # Collections state
    collections = Reactant(Collection[])
    colentry = Reactant("")
    selected_collection = Reactant{Union{Collection, Nothing}}(nothing)

    # Todos state
    todos = Reactant(Todo[])
    todoentry = Reactant("")

    # Filtered todos based on the selected collection
    filtered_todos = @reactor begin
        isnothing(selected_collection') ? Todo[] :
            filter(t -> t.collectionid == selected_collection'.id, todos')
    end

    onmount() do _, ctx
        user = getdata(ctx)[:user]
        @ionic begin
            username' = user.name
            collections' = getstores(ctx)[:collections]'
            todos' = getstores(ctx)[:todos]'
        end
        # Persist changes back to the store
        @radical getstores(ctx)[:collections]' = collections'
        @radical getstores(ctx)[:todos]' = todos'
    end

    return efus"""
    VBox
      Label text="<big>Hello $(username')</big>, welcome to your Todolist" margin=10
      Separator
      HPaned expand=true
        # Left Pane: Collections
        Frame box:orient=O_V cssclasses=["collections-list"]
          Label text="<b>Collections</b>"
          ScrolledWindow expand=true
            VBox
              For items=collections
                builder(coll)
                  Button text=(coll.name) cssclasses=["collection-button"] onclick=() -> (selected_collection'=coll)
                end
          HBox expand=(false, true)
            Entry text=colentry placeholder="New Collection"
            Button text="Add" onclick=()->(
              push!(collections', Collection(userid=user.id, name=colentry'));
              notify(collections);
              colentry' = ""
            )
        # Right Pane: Todos
        Frame box:orient=O_V
          Switched value=(!isnothing(selected_collection'))::Bool box:expand=false box:align=(nothing, A_C)
            builder()
              if !isnothing(selected_collection')
                VBox
                  Label text="<big><b>$(selected_collection'.name)</b></big>" margin=10
                  ScrolledWindow expand=true
                    VBox
                      For items=filtered_todos
                        builder(todo)
                          Frame cssclasses=["todo-item"]
                            Label text=(todo.text) margin=15
                        end
                  HBox expand=(false, true)
                    Entry text=todoentry placeholder="New Todo"
                    Button text="Add" onclick=() -> (
                      push!(todos', Todo(collectionid=selected_collection'.id, text=todoentry'));
                      notify(todos);
                      todoentry' = ""
                    )
              else
                Label text="Select a collection to start" margin=50
              end
            end
    """
end

const Home = ReloadablePage(HomeContent)
