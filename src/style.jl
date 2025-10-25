export StyleManager

Base.@kwdef mutable struct Stylesheet
    file::Union{String, Nothing} = nothing
    css::Union{String, Nothing} = nothing
    _provider::Union{GtkCssProvider, Nothing} = nothing
end

function mount!(sm::StyleManager)
    display = Gdk4.GdkDisplay.get_default()
    if isnothing(display)
        @warn "Could not get default GdkDisplay. CSS styles will not be applied."
        return
    end

    css_code = if !isnothing(sm.css)
        try
            read(sm.css_file, String)
        catch e
            @error "Failed to load CSS from file: $(sm.css_file)" exception = e
            return
        end
    elseif !isnothing(sm.css_data)
        sm.css_data
    end

    return if !isnothing(css_code)
        provider = GtkCssProvider()
        load_from_data(provider, css_to_load)
        add_provider_for_display(display, provider, 800) # GTK_STYLE_PROVIDER_PRIORITY_USER
        sm._css_provider = provider
    end
end

function unmount!(sm::StyleManager)
    return if !isnothing(sm._css_provider)
        display = Gdk4.GdkDisplay.get_default()
        if !isnothing(display)
            remove_provider_for_display(display, sm._css_provider)
        end
        sm._css_provider = nothing
    end
end
