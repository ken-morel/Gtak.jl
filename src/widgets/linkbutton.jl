export LinkButton

export LinkButton

"""
    LinkButton(; uri, text=nothing, kwargs...)

A button that acts as a hyperlink, opening the specified URI when clicked.
"""
@gtakwidgetcomponent LinkButton  begin
    "The URI to open when the button is clicked."
    uri::MayBeReactive{<:AbstractString}
    "The text to display on the button. If not provided, the URI will be displayed."
    text::Union{MayBeReactive{<:AbstractString}, Nothing} = nothing
end

function mount!(lb::LinkButton, p::GtakComponent)
    @lock lb begin
        lb._parent = p
        lb._widget = GtkLinkButton(lb.link)
        _gtakwidgetmountcommon!(lb, [])
        return lb._widget
    end
end

function update!(l::LinkButton)
    return _updates(l) do dirt
        if dirt == :uri
            l._widget.uri = resolve(l.uri)
        elseif dirt == :text && !isnothing(l.text)
            l._widget.label = resolve(l.text)
        end
    end
end
