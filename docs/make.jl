using Documenter
using Foldseek

cp(joinpath(@__DIR__, "..", "README.md"), joinpath(@__DIR__, "src", "index.md"); force = true)

makedocs(;
    modules = [Foldseek],
    authors = "Carlos Vigil-Vásquez <carlos.vigil.v@gmail.com> and contributors",
    sitename = "Foldseek.jl",
    format = Documenter.HTML(;
        canonical = "https://cvigilv.github.io/Foldseek.jl",
        edit_link = "main",
        assets = String[],
    ),
    pages = [
        "Home" => "index.md",
        "API Reference" => "api.md",
    ],
    checkdocs = :exports,
)

deploydocs(;
    repo = "github.com/cvigilv/Foldseek.jl",
    devbranch = "main",
)
