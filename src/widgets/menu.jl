export Menu, MenuItem, SubMenu, MenuSeparator

using Gtk4.GLib


@gtakwidgetcomponent MenuButton <: AbstractMenuItem begin
    label::MayBeReactive{String}
    onclick::Union{Function, Nothing} = nothing
    _action_name::Union{String, Nothing} = nothing
end
@gtakwidgetcomponent MenuCheckbox <: AbstractMenuItem begin
    label::MayBeReactive{String}
    checked::MayBeReactive{Bool} = false
    onclick::Union{Function, Nothing} = nothing
    _action_name::Union{String, Nothing} = nothing
end
@gtakcomponent MenuSeparator <: AbstractMenuItem begin
end

@gtakcomponent SubMenu <: AbstractMenuItem begin
    label::MayBeReactive{String}
    items::Vector{AbstractMenuItem} = AbstractMenuItem[]
end


@gtakcomponent Menu <: AbstractMenu begin
    items::Vector{AbstractMenuItem} = AbstractMenuItem[]
end

menuitem(::MayBeReactive{<:AbstractString}, m::SubMenu) = m
menuitem(label::MayBeReactive{<:AbstractString}, onclick::Function) = MenuItem(; label, onclick)
menuitem(label::MayBeReactive{<:AbstractString}, checked::MayBeReactive{Bool}) = MenuCheckBox(; label, checked)
menuitem(label::MayBeReactive{<:AbstractString}, content::Vector{<:Pair}) = SubMenu(; label, items = menuitems(content))
menuitem(::MayBeReactive{<:AbstractString}, val) = error("Invalid menu action value $val")

menuitems(items::Vector{<:Pair}) = [menuitem(name, value) for (name, value) in items]
Menu(items::Pair{<:MayBeReactive{<:AbstractStrteing}, <:Any}...) = Menu(items = menuitems(items))

const AbstractMenuContainer = Union{AbstractMenu, AbstractMenu}


function IonicEfus.mount!(c::Menu, app::AbstractGtakApplication)
    @lock c begin
        c._parent = app
        c._widget = GMenu()
        actions = GActionMap(app)
        for item in c.items
            mount!(item, c, actions, c._widet)
        end
        app.menubar = c._widget
        return c._widget
    end
end

function IonicEfus.mount!(c::MenuButon, p::AbstractMenuContainer, actions::GActionMap, parent_menu::GMenu)
    return @lock c begin
        c._parent = p
        label = resolve(c.label)
        action_name = "app." * replace(lowercase(label), r"[^a-z0-9_]" => "_") * "_" * string(hash(label), base = 62)
        add_action(actions, action_name, c.onclick)
        c._widget = GMenuIem(resolve(c.label), action_name)
        push!(parent_menu, c._widget)
    end

end
function IonicEfus.mount!(c::SubMenu, p::AbstractMenuContainer, actions::GActionMap, parent_menu::GMenu)
    @lock c begin
        c._parent = p
        c._widget = GMenu()
        for item in c.items
            mount!(item, c, actions, c._widget)
        end
        Gtk4.submenu(parent_menu, resolve(c.label), c._widget)
        return c._widget
    end
end

function IonicEfus.mount!(c::MenuSeparator, app::GtkApplication, parent_menu::GMenu)
    c._parent = app
    # GTK4 uses sections for separators. We add an anonymous section.
    Gtk4.menu_append_section(parent_menu, nothing, GMenu())
    return nothing
end
