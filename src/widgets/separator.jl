export Separator

@gtakwidgetcomponent Separator <: GtakWidgetComponent begin
    orient::Orientation = O_H
end

params(::Type{Separator}) = Set{Symbol}([:orient])

function mount!(s::Separator, p::GtakComponent)
    s.parent = p
    s.widget = GtkSeparator(s.orient)
    return s.widget
end
