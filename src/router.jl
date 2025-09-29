export Router


struct Router
    history::Vector{AbstractPage}
    current_page::Reactant{Union{AbstractPage, Nothing}}
    Router() = new([], Reactant{Union{AbstractPage, Nothing}}(nothing))
end

function Base.push!(r::Router, p::AbstractPage; replace::Bool = false)
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

function reload!(r::Router; all::Bool = false)
    if all
        reload!.(r.history)
    end
    page = getvalue(r.current_page)
    return if !isnothing(page)
        reload!(page)
    end
end
