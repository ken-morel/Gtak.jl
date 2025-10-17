export LinkButton

@gtakwidgetcomponent LinkButton <: GtakWidgetComponent begin
    uri::MayBeReactive{String}
    text::Union{MayBeRactive{String}, Nothing} = nothing
end

function mount!(lb::LinkButton, p::GtakComponent)
    lb._parent = p
    lb._widget = GtkLinkButton(lb.link)
    _gtakwidgetmountcommon!(b, [])
    return lb._widget
end

function update!(l::LinkButton)
    return _updates(l) do dirt
        if dirt == :uri
            l._widget.uri = resolve(String, l.uri)
        elseif dirt == :text && !isnothing(l.text)
            l._widget.label = resolve(String, l.text)
        end
    end
end
