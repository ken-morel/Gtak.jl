const Id = UInt
create_id()::Id = time_ns()

Base.@kwdef struct User
    id::Id = create_id()
    name::String
    password::String
end
Base.@kwdef struct Todo
    id::Id = create_id()
    userid::Id
    text::String
end
function setupstores!(app)
    st = app.stores
    st[:root] = store(configdirs(app)[1])
    st[:users] = collection(st[:root], :users, User)
    st[:todos] = collection(st[:root], :todos, Todo)
    return
end
