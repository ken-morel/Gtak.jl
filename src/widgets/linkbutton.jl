export LinkButton

@gtakwidgetcomponent LinkButton <: GtakWidgetComponent begin
    link::String
    text::String = link
end

params(::Type{LinkButton}) = Set{Symbol}([:link, :text])

function mount!(lb::LinkButton, p::GtakComponent)
    lb.parent = p
    lb.widget = GtkLinkButton(lb.link, lb.text)
    return lb.widget
end
