createapplication() = application("com.example.tod", stylesheet=todstyle) do app
    setupstores!(app)
    app.data[:user] = nothing
    window(app; title = "Gtak Todolist") do _
        Pages.Login
    end
end
