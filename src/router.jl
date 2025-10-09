export Router

struct Router
    history::Vector{AbstractPage}
    current_page::Reactant{Union{AbstractPage, Nothing}}
    scheduler::Scheduler
    Router(scheduler::Scheduler) = new([], Reactant{Union{AbstractPage, Nothing}}(nothing), scheduler)
end

function Base.push!(r::Router, p::AbstractPage; replace::Bool = false)
    if !replace
        page = getvalue(r.current_page)
        if !isnothing(page)
            push!(r.history, page)
        end
    end
    setscheduler!(p, r.scheduler)
    setvalue!(r.current_page, p)
    return p
end

function Base.pop!(r::Router)
    current = getvalue(r.current_page)
    if !isnothing(current)
        setscheduler!(current, nothing)
    end
    page = isempty(r.history) ? nothing : pop!(r.history)
    setvalue!(r.current_page, page)
    return page
end

function reload!(r::Router; all::Bool = false)
    if all
        foreach(reload!, r.history)
    end

    page = getvalue(r.current_page)
    return if !isnothing(page)
        reload!(page)
    end
end
