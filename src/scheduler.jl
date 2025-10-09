export Scheduler, schedule!, start!, stop!, Priority

@enum Priority begin
    UserInteractive = 1
    High = 2
    Normal = 3
    Low = 4
end

struct PriorityTask
    callback::Function
    priority::Priority
    id::UInt64 # Tie-breaker for tasks with the same priority (FIFO)
end

# Custom comparison for the heap. Higher priority (lower enum value) comes first.
Base.isless(a::PriorityTask, b::PriorityTask) =
    (a.priority < b.priority) || (a.priority == b.priority && a.id < b.id)

# --- Minimal Binary Heap Implementation ---
mutable struct BinaryHeap{T}
    nodes::Vector{T}
    counter::UInt64 # Used to assign unique IDs to tasks for FIFO tie-breaking

    BinaryHeap{T}() where {T} = new{T}(Vector{T}(), 0)
end

Base.isempty(h::BinaryHeap) = isempty(h.nodes)
Base.length(h::BinaryHeap) = length(h.nodes)

function Base.push!(h::BinaryHeap{T}, val::T) where {T}
    push!(h.nodes, val)
    sift_up!(h, length(h.nodes))
end

function Base.pop!(h::BinaryHeap)
    isempty(h) && return nothing
    # Swap the root with the last element
    x = h.nodes[1]
    last = pop!(h.nodes)
    if !isempty(h)
        h.nodes[1] = last
        sift_down!(h, 1)
    end
    return x
end

function sift_up!(h::BinaryHeap, i::Int)
    i == 1 && return
    parent = i >> 1
    while i > 1 && isless(h.nodes[i], h.nodes[parent])
        h.nodes[i], h.nodes[parent] = h.nodes[parent], h.nodes[i]
        i = parent
        parent = i >> 1
    end
end

function sift_down!(h::BinaryHeap, i::Int)
    n = length(h.nodes)
    while true
        left = i << 1
        right = left + 1
        smallest = i

        if left <= n && isless(h.nodes[left], h.nodes[smallest])
            smallest = left
        end
        if right <= n && isless(h.nodes[right], h.nodes[smallest])
            smallest = right
        end

        if smallest != i
            h.nodes[i], h.nodes[smallest] = h.nodes[smallest], h.nodes[i]
            i = smallest
        else
            break
        end
    end
end
# --- End of Heap ---

Base.@kwdef mutable struct Scheduler
    heap::BinaryHeap{PriorityTask} = BinaryHeap{PriorityTask}()
    const lock::ReentrantLock = ReentrantLock()
    const work_signal::Threads.Condition = Threads.Condition()
    workers::Vector{Task} = []
    num_workers::Int = Threads.nthreads()
    is_running::Bool = false
end

function schedule!(s::Scheduler, cb::Function, p::Priority)
    @lock s.lock begin
        s.heap.counter += 1
        task = PriorityTask(cb, p, s.heap.counter)
        push!(s.heap, task)
        Threads.notify(s.work_signal)
    end
end

function start!(s::Scheduler)
    @lock s.lock begin
        if s.is_running
            return
        end
        s.is_running = true
        for i in 1:s.num_workers
            task = Threads.@spawn worker_loop(s)
            push!(s.workers, task)
        end
    end
end

function stop!(s::Scheduler)
    @lock s.lock begin
        if !s.is_running
            return
        end
        s.is_running = false
        Threads.notify(s.work_signal; all = true)
    end
    # Wait for all worker tasks to finish
    foreach(wait, s.workers)
    empty!(s.workers)
end

function worker_loop(s::Scheduler)
    while @lock s.lock s.is_running
        task = @lock s.lock begin
            while isempty(s.heap) && s.is_running
                Threads.wait(s.work_signal)
            end
            # Check is_running again after wait, in case of shutdown
            s.is_running ? pop!(s.heap) : nothing
        end

        if !isnothing(task)
            try
                task.callback()
            catch e
                Base.printstyled(stderr, "Error in scheduled task:\n"; color = :red, bold = true)
                Base.showerror(stderr, e, catch_backtrace())
                println(stderr)
            end
        end
    end
end
