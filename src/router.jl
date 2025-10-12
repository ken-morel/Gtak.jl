export Router

"""
A gtak router manages a current_page
and a history of pages.
"""
struct Router
    history::Vector{AbstractPage}
    current_page::Reactant{Union{AbstractPage, Nothing}}
    Router() = new([], Reactant{Union{AbstractPage, Nothing}}(nothing))
end

"""
    Base.push!(r::Router, p::AbstractPage; replace::Bool = false)

Show the page on the router, if replace is true,
it does not send the current page to history.
"""
function Base.push!(r::Router, p::AbstractPage; replace::Bool = false)
    if !replace
        page = getvalue(r.current_page)
        if !isnothing(page)
            push!(r.history, page)
        end
    end
    setvalue!(r.current_page, p)
    return p
end

"""
    Base.pop!(r::Router)

Remove the current page and replace with the last
from history, or nothing.
"""
function Base.pop!(r::Router)
    page = isempty(r.history) ? nothing : pop!(r.history)
    setvalue!(r.current_page, page)
    return page
end

"Reload all or only the current page in router"
function reload!(r::Router; all::Bool = false)
    if all
        foreach(reload!, r.history)
    end

    page = getvalue(r.current_page)
    return if !isnothing(page)
        reload!(page)
    end
end
