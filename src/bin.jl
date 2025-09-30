using Base.Threads: @lock, ReentrantLock

export DirtBin, clean!, start!, stop!

Base.@kwdef mutable struct DirtBin
    cleanafter::Real = 0.1
    const lock::ReentrantLock = ReentrantLock()
    const dirt::Set{GtakComponent} = Set{GtakComponent}()
    running::Bool = false
    task::Union{Task, Nothing} = nothing
end

function Base.push!(d::DirtBin, c::GtakComponent)
    @lock d.lock push!(d.dirt, c)
    return c
end

function clean!(b::DirtBin)
    while true
        comp = @lock b.lock begin
            isempty(b.dirt) ? nothing : pop!(b.dirt)
        end
        if !isnothing(comp)
            update!(comp)
        else
            break
        end
    end
    return
end

function start!(b::DirtBin; force::Bool = false)
    return @lock b.lock begin
        if b.running && !force
            return
        end
        b.task = errormonitor(
            @async begin
                b.running = true
                try
                    while (@lock b.lock b.running)
                        comp = @lock b.lock (isempty(b.dirt) ? nothing : pop!(b.dirt))
                        if comp === nothing
                            sleep(b.cleanafter)
                        else
                            try
                                update!(comp)
                            catch e
                                Base.printstyled(stderr, "In Dirt Bin\n"; color = :red, bold = true)
                                Base.showerror(stderr, e)
                            end
                        end
                    end
                finally
                    @lock b.lock begin
                        if b.task == current_task()
                            b.running = false
                            b.task = nothing
                        end
                    end
                end
            end
        )
    end

end

function stop!(b::DirtBin)
    @lock b.lock b.running = false
    return
end
