export LinkButton

@gtakwidgetcomponent LinkButton  begin
    uri::MayBeReactive{String}
    text::Union{MayBeReactive{String}, Nothing} = nothing
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
            l._widget.uri = resolve(String, l.uri)
        elseif dirt == :text && !isnothing(l.text)
            l._widget.label = resolve(String, l.text)
        end
    end
end
