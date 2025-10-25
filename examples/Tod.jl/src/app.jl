createapplication() = application("com.example.tod") do app
    setupstores!(app)
    app.data[:user] = nothing
    window(app; title = "Gtak application") do _
        Pages.Login
    end
end
