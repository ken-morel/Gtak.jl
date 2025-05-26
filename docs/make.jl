using Gtak
using Documenter

DocMeta.setdocmeta!(Gtak, :DocTestSetup, :(using Gtak); recursive=true)

makedocs(;
    modules=[Gtak],
    authors="Engon Ken Morel <engonken8@gmail.com> and contributors",
    repo="https://github.com/ken-morel/Gtak.jl/blob/{commit}{path}#{line}",
    sitename="Gtak.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://ken-morel.github.io/Gtak.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/ken-morel/Gtak.jl",
    devbranch="main",
)
