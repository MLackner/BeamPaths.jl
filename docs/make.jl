using BeamPaths
using Documenter

DocMeta.setdocmeta!(BeamPaths, :DocTestSetup, :(using BeamPaths); recursive=true)

makedocs(;
    modules=[BeamPaths],
    authors="Michael Lackner",
    repo="https://github.com/MLackner/BeamPaths.jl/blob/{commit}{path}#{line}",
    sitename="BeamPaths.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://MLackner.github.io/BeamPaths.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/MLackner/BeamPaths.jl",
    devbranch="main",
)
