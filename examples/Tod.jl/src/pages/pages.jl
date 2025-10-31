module Pages
using Markdown
using ...Tod: User, Todo, Collection
using Gtak

username = Reactant("")

include("./login.jl")
include("./home.jl")
end
