export LinkButton

@gtakcomponent LinkButton <: GtakWidgetComponent begin
    link::String
    text::String = link
end

IonicEfus.params(::Type{LinkButton}) = Set{Symbol}([:link, :text])

function IonicEfus.mount!(lb::LinkButton, p::GtakComponent)
    lb.parent = p
    lb.widget = GtkLinkButton(lb.link, lb.text)
    return lb.widget
end
