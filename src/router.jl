export Router

struct Router
    history::Vector{Page}
    current_page::Reactant{Union{Page, Nothing}}
    Router() = new([], Reactant{Union{Page, Nothing}}(nothing))
end

function Base.push!(r::Router, p::Page; replace::Bool = false)
    if !replace
        page = getvalue(r.current_page)
        if !isnothing(page)
            push!(r.history, page)
        end
    end
    return setvalue!(r.current_page, p)
end
function Base.pop!(r::Router)
    return if isempty(r.history)
        setvalue!(r.current_page, nothing)
    else
        setvalue!(r.current_page, r.history[end])
        pop!(r.history)
    end
end
