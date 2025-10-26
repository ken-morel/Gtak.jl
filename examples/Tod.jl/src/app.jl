createapplication() = application("com.example.tod") do app
    setupstores!(app)
    app.data[:user] = nothing
    window(app; title = "Gtak application", stylesheet = TODSTYLE) do _
        Pages.Login
    end
end
