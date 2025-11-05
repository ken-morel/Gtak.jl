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
    old_content = c._content
    
    new_data_set = Set(new_tabs_data)
    old_data_set = Set(cache.value for cache in old_content)

    to_add = setdiff(new_data_set, old_data_set)
    to_remove = setdiff(old_data_set, new_data_set)

    # --- 1. Handle Removals --- 
    if !isempty(to_remove)
        # We must get all page numbers before deleting, as indices will shift.
        pages_to_delete = []
        caches_to_remove = []
        for cache in old_content
            if cache.value in to_remove
                page = Gtk4.pagenumber(c._widget, cache.tab._content)
                if page != -1
                    push!(pages_to_delete, (page, cache))
                end
            end
        end

        # Sort by page number descending to delete from the end
        sort!(pages_to_delete, by = x -> x[1], rev = true)

        for (page, cache) in pages_to_delete
            deleteat!(c._widget, page + 1) # deleteat! is 1-indexed
            unmount!(cache.tab)
        end

        # Update the internal cache
        filter!(cache -> !(cache.value in to_remove), old_content)
    end

    # --- 2. Handle Additions --- 
    if !isempty(to_add)
        data_to_new_idx = Dict(data => i for (i, data) in enumerate(new_tabs_data))
        
        # We need to sort the new tabs by their target index to insert them correctly
        sorted_new_data = sort(collect(to_add), by = data -> data_to_new_idx[data])

        for data in sorted_new_data
            target_idx = data_to_new_idx[data]
            builder_output = @invokelatest c.builder(data)
            tab = isempty(builder_output) ? nothing : first(builder_output)
            if tab isa NotebookTab
                (content_widget, label_widget) = mount!(tab, c)
                # Gtk insert is 0-indexed
                insert!(c._widget, target_idx - 1, content_widget, label_widget)
                # Julia insert is 1-indexed
                insert!(old_content, target_idx, (value=data, tab=tab))
            end
        end
    end

    # Note: This implementation correctly handles additions and removals without a full redraw.
    # Reordering of existing items is not handled to avoid the complexity and risk of a full redraw.
    c._content = old_content
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

