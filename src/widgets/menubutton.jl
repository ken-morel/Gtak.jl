export MenuButton

@gtakwidgetcomponent struct MenuButton
    label::MayBeReactive{<:Any}
    hasframe::Union{MayBeReactive{Bool},Nothing} = nothing
    overflow::Union{MayBeReactive{Gtk4.Overflow},Nothing} = nothing
    showarrow::MayBeReactive{Bool} = false
    primary::MayBeReactive{Bool} = false
    iconname::Union{MayBeReactive{<:AbstractString},Nothing} = nothing
    useunderline::MayBeReactive{Bool} = false
    menumodel::MayBeReactive{<:Any} = nothing
    menu::Union{Menu,Nothing} = nothing
end
function mount!(m::MenuButton, p::GtakComponent)
    @lock m begin
        m._parent = p
        m._widget = GtkMenuButton()
        _gtakwidgetmountcommon!(m, [])
        return m._widget
    end
end

function update!(m::MenuButton)
    _updates(m) do dirt
        if dirt ∈ Set((:label, :overflow, :primary))
            setpropertyonce!(m._widget, dirt, resolve(getproperty(m, dirt)))
        elseif dirt == :hasframe
            m._widget.has_frame = resolve(m.hasframe)
        elseif dirt == :showarrow
            m._widget.always_show_arrow = resolve(m.showarrow)
        elseif dirt == :menumodel
            m._widget.menu_model = resolve(m.menumodel)
        elseif dirt == :menu
            menu = mount!(m.menu)
            m._widget.menu_model = menu
        end
    end
end
