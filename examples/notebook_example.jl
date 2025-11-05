using Gtak

# Define the data structure for our tabs
mutable struct TabInfo
    id::Int
    title::String
end
Base.:(==)(a::TabInfo, b::TabInfo) = a.id == b.id

# Define the global reactive state for the application
const TABS = Reactant(
    [
        TabInfo(1, "Tab One"),
        TabInfo(2, "Tab Two"),
    ]
)
const SELECTED_TAB = Reactant{Union{TabInfo, Nothing}}(nothing)
const NEXT_ID = Reactant(3)


# Callback to add a new tab
@ionic function add_tab()
    new_tab = TabInfo(NEXT_ID', "Tab $(NEXT_ID')")
    NEXT_ID' = NEXT_ID' + 1
    # Create a new vector and set the reactant's value to trigger an update
    return setvalue!(TABS, [TABS'..., new_tab])
end

# Callback to remove the last tab
@ionic function remove_last_tab()
    return if !isempty(TABS')
        new_tabs = TABS'[1:(end - 1)]
        setvalue!(TABS, new_tabs)
    end
end

# Callback to programmatically select the first tab
@ionic function select_first_tab()
    return if !isempty(TABS')
        setvalue!(SELECTED_TAB, TABS'[1])
    end
end

# Application entry point
(@main)(_) = application("com.example.notebookexample") do app
    window(app, title = "Notebook Example") do _
        staticpage"""
        VBox spacing=10 margin=10
            HBox spacing=10
                Button text="Add Tab" onclick=add_tab
                Button text="Remove Last Tab" onclick=remove_last_tab
                Button text="Select First Tab" onclick=select_first_tab
            Label text=("Selected Tab ID: $(SELECTED_TAB' === nothing ? "None" : SELECTED_TAB'.id)")
            Notebook tabs=TABS tab=SELECTED_TAB
              builder(info)
                NotebookTab label="Tab #$(info.id)"
                  VBox spacing=10 margin=10
                      Label text="This is the content for tab with ID: $(info.id)"
                      Label text="Title: $(info.title)"
              end
        """
    end
end |> run

