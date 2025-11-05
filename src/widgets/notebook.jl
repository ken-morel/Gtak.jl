export Notebook, NotebookTab


@gtakwidgetcomponent struct Notebook
    const children::Components = Components()
    tabs::MayBeReactive{<:AbstractVector} = []
    builder::Union{Function, Snippet, Nothing} = nothing
    tab::MayBeReactive{<:Any} = nothing

    _content::Vector{Any} = [] # Cache for dynamic tabs: Vector of (value, tab_component)
    _switch_page_signal_id::UInt = 0
end

@gtakcomponent struct NotebookTab <: GtakComponent
    const children::Components = Components()
    label::MayBeReactive{<:AbstractString}
    _label::Union{GtkLabel, Nothing} = nothing
    _content::Union{GtkBox, Nothing} = nothing
end

function mount!(tb::NotebookTab, nb::Notebook)
    @lock tb begin
        tb._parent = nb
        tb._label = GtkLabel(resolve(tb.label))
        tb._content = GtkBox(Gtk4.Orientation_HORIZONTAL)
        push!.(Ref(tb._content), mount!.(tb.children, Ref(tb)))

        if tb.label isa AbstractReactive
            catalyze!(tb._catalyst, tb.label) do label
                schedule(tb, Sched.ComponentUpdate(tb, Sched.Normal)) do
                    tb._label.label = resolve(label)
                end
            end
        end
        return tb._content, tb._label
    end
end

function unmount!(tb::NotebookTab)
    return @lock tb begin
        unmount!.(tb.children)
        denature!(tb._catalyst)
        tb._label = nothing
        tb._content = nothing
    end
end

function mount!(c::Notebook, p::GtakComponent)
    @lock c begin
        c._parent = p
        c._widget = GtkNotebook()

        _gtakwidgetmountcommon!(c, [])

        if c.builder !== nothing && !isempty(c.children)
            @warn "Notebook cannot have both a builder and static children."
        end

        mount_static!(c)

        c._switch_page_signal_id = signal_connect(c._widget, "switch-page") do _, _, page_num
            if c.tab isa AbstractReactive && c.builder !== nothing
                schedule(
                    c, Sched.ReactantUpdate(c.tab, Sched.Normal) do
                        if page_num < length(c._content)
                            selected_data = c._content[page_num + 1].value
                            setvalue!(c.tab, selected_data)
                        end
                    end
                )

            end
        end

        return c._widget
    end
end

function mount_static!(c::Notebook)
    for (i, child) in enumerate(c.children)
        if !(child isa NotebookTab)
            @warn "Notebook children can only be NotebookTab, not $(typeof(child))"
            continue
        end
        (widget, label) = mount!(child, c)
        push!(c._widget, widget, label)
    end
    return
end

function update!(c::Notebook)
    return _updates(c) do dirt
        if dirt == :tabs && c.builder !== nothing
            updatetabs!(c, resolve(c.tabs))
        elseif dirt == :tab && c.builder !== nothing
            selected_data = resolve(c.tab)
            if selected_data !== nothing
                idx = findfirst(x -> x.value == selected_data, c._content)
                if idx !== nothing && c._widget.page != idx - 1
                    c._widget.page = idx - 1
                end
            end
        end
    end
end

function updatetabs!(c::Notebook, new_tabs_data::AbstractVector)
    new_content = []
    old_content = c._content

    # Find tabs to remove
    to_remove_indices = [i for (i, cache) in enumerate(old_content) if findfirst(==(cache.value), new_tabs_data) === nothing]
    for i in reverse(to_remove_indices)
        cache = popat!(old_content, i)
        unmount!(cache.tab)
    end

    # Add new tabs and reorder existing ones
    for data in new_tabs_data
        existing_cache = nothing
        for cache in old_content
            if cache.value == data
                existing_cache = cache
                break
            end
        end

        if existing_cache !== nothing
            push!(new_content, existing_cache)
        else
            builder_output = @invokelatest c.builder(data)
            tab = isempty(builder_output) ? nothing : first(builder_output)
            if tab isa NotebookTab
                mount!(tab, c)
                push!(new_content, (; value = data, tab = tab))
            else
                @warn "Notebook builder must return a NotebookTab, not $(typeof(tab))"
            end
        end
    end

    empty!(c._widget)
    for cache in new_content
        push!(c._widget, cache.tab._content, cache.tab._label)
    end
    return c._content = new_content
end

function unmount!(c::Notebook)
    return @lock c begin
        if c._widget !== nothing && c._switch_page_signal_id != 0
            signal_handler_disconnect(c._widget, c._switch_page_signal_id)
            c._switch_page_signal_id = 0
        end

        for cache in c._content
            unmount!(cache.tab)
        end
        empty!(c._content)

        _gtakunmountwidget!(c)
    end
end

