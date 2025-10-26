export Stylesheet, @stylesheet_str

export Stylesheet, @stylesheet_str

import Gtk4: GtkCssProvider

Base.@kwdef mutable struct Stylesheet
    file::Union{String, Nothing} = nothing
    css::Union{String, Nothing} = nothing
    _provider::Union{GtkCssProvider, Nothing} = nothing
    _display::Union{Gtk4.GdkDisplay, Nothing} = nothing
end

macro stylesheet_str(code::String)
    return Stylesheet(css = code)
end

function mount!(sm::Stylesheet, display::Gtk4.GdkDisplay)
    css_code = if !isnothing(sm.file)
        try
            read(sm.file, String)
        catch e
            @error "Failed to load CSS from file: $(sm.file)" exception = e
            ""
        end
    elseif !isnothing(sm.css)
        sm.css
    end

    if !isnothing(css_code)
        provider = GtkCssProvider(css_code)
        push!(display, provider, 800) # GTK_STYLE_PROVIDER_PRIORITY_USER
        sm._provider = provider
        sm._display = display
    end
    return sm._provider
end

function unmount!(sm::Stylesheet)
    return if !isnothing(sm._provider) && !isnothing(sm._display)
        delete!(sm._display, sm._provider)
        sm._provider = nothing
        sm._display = nothing
    end
end
