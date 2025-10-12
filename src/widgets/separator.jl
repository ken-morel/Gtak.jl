export Separator

@gtakcomponent Separator <: GtakWidgetComponent begin
    orient::Orientation = OH
end

IonicEfus.params(::Type{Separator}) = Set{Symbol}([:orient])

function IonicEfus.mount!(s::Separator, p::GtakComponent)
    s.parent = p
    s.widget = GtkSeparator(s.orient)
    return s.widget
end

function IonicEfus.unmount!(s::Separator)
    return _gtakunmountwidget!(s)
end
