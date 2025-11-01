function on_new_clicked(app)
    return println("New menu item clicked!")
end

function on_open_clicked(app)
    return println("Open menu item clicked!")
end

function on_toggle_setting(app)
    return println("Toggle setting menu item clicked!")
end

createapplication() = application(
    "com.example.tod", stylesheet = todstyle, menubar = Menu(
        "File" => [
            "New" => on_new_clicked,
            "Open" => on_open_clicked,
            "" => nothing,
            "Exit" => (app) -> Gtk4.quit(app),
        ],
        "Settings" => [
            "Toggle Feature" => Reactant(false),
            "Theme" => [
                "Light" => (app) -> println("Set theme to Light"),
                "Dark" => (app) -> println("Set theme to Dark"),
            ],
        ]
    )
) do app
    setupstores!(app)
    app.data[:user] = nothing
    window(app; title = "Gtak Todolist") do _
        Pages.Login
    end
end
