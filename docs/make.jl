using Documenter, StructDualDynProg

makedocs(
    format = :html,
    sitename = "StructDualDynProg",
    pages = [
        "Home" => "index.md",
        "Quick Start" => "quickstart.md",
        "Tutorial" => "tutorial.md",
        "Stopping Criterion" => "stopcrit.md"
    ],
    # The following ensures that we only include the docstrings from
    # this module for functions define in Base that we overwrite.
    modules = [StructDualDynProg]
)

deploydocs(
    repo   = "github.com/JuliaStochOpt/StructDualDynProg.jl.git",
    target = "build",
    osname = "linux",
    julia  = "0.6",
    deps   = nothing,
    make   = nothing
)
