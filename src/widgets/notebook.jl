export Notebook, NotebookPage

using ..Gtak: Keyed

const _NbContent = @NamedTuple{value, tab}

@gtakwidgetcomponent struct Notebook
    const children::Components = Components()
    tabs::MayBeReactive{<:AbstractVector} = []
    builder::Union{Function, Snippet, Nothing} = nothing
    tab::MayBeReactive{<:Any} = nothing

    _content::Vector{Tuple} = Tuple[]
    _switch_page_signal_id::UInt = 0
end

@gtakcomponent  struct NotebookTab <: Component
    const children::Components = Components
    label::MayBeReactive{<:AbstractString}
    _label::Union{GtkLabel, Nothing} = nothing
    _content::Union{Vector, Nothing} = nothing
end
function mount!(tb::NotebookTab, nb::Notebook)
    return @lock tb begin
        tb._parent = nb
        tb._label = GtkLabel(resolve(tb.label))
        tb._content = GtkBox(O_H)
        push!.((tb._content,), mount!.(tb.children, tb))
        tb.label isa AbstractReactive && catalyze!(tb.catalyst, tb.label) do _
            schedule(tb, Sched.ComponentUpdate(tb, Sched.Normal)) do
                tb._label.label = resolve(tb.label)
            end
        end
    end
end

function unmount!(tb::NotebookTab)
    return @lock tb begin
        unmount!.(tb.children)
        denature!(tb.catalyst)
        tb._label = nothing
        tb._content = nothing
    end
end


function mount!(c::Notebook, p::GtakComponent)
    @lock c begin
        c._parent = p
        c._widget = GtkNotebook()

        _gtakwidgetmountcommon!(c, [])

        is_dynamic = c.builder !== nothing

        if is_dynamic && !isempty(c.children)
            @warn "Notebook cannot have both a builder and static children."
        end


        mount_static!(c)

        c._switch_page_signal_id = signal_connect(c._widget, "switch-page") do _, _, page_num
            if c.tab isa AbstractReactive
                schedule(
                    c, Sched.ReactantUpdate(c.tab, Sched.Normal) do
                        if page_num < length(c._tab_data)
                            selected_data = c._tab_data[page_num + 1]
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

        push!(c._widget, label, widget)
    end
    return
end

function update!(c::Notebook)
    return _updates!(c) do dirt
        if dirt == :tabs
            updatetabs!(c, resolve(c.tabs))
        end
    end
end

function updatetabs!(c::Notebook, new_tabs::AbstractVector)
    # T, comp, lbl

    newcache = Tuple[]
    oldcache = c._cache
    for (idx, cache) in reverse(enumerate(copy(oldcache)))
        if isnothing(findfirst(==(cache.value), new_tabs))
            popat!(oldcache, idx, nothing)
            unmount!(cache.tab)
        end
    end
    for data in new_tabs
        found = false
        for cache in oldcache
            if cache.value == data
                push!(newcache, cache)
                found = true
                break
            end
        end
        if !found
            content = @invokelatest c.builder(data)
            tab = if empty(content)
                continue
            else
                first(content)
            end
            if !(tab isa NotebookTab)
                @warn "Notebook builder must return notebook tabs, not $(typeof(tab))"
                continue
            end
            mount!(tab)
            push!(newcache, (; tab, value = data))
        end
    end
    empty!(c._widget)
    for cache in newcache
        push!(c._widget, cache.tab._content, cache.tab._label)
    end
    c._cache = newcache
    return
end

function unmount!(c::Notebook)
    return @lock c begin
        if c._widget !== nothing && c._switch_page_signal_id != 0
            signal_handler_disconnect(c._widget, c._switch_page_signal_id)
            c._switch_page_signal_id = 0
        end

        for component in values(c._mounted_tabs)
            unmount!(component)
        end
        empty!(c._mounted_tabs)
        empty!(c._tab_data)

        _gtakunmountwidget!(c)
    end
end

