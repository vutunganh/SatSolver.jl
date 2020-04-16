using Documenter, SatSolver

makedocs(;
    modules=[SatSolver],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/vutunganh/SatSolver.jl/blob/{commit}{path}#L{line}",
    sitename="SatSolver.jl",
    authors="Tung Anh Vu <vu.tunganh96@gmail.com>",
    assets=String[],
)

deploydocs(;
    repo="github.com/vutunganh/SatSolver.jl",
)
