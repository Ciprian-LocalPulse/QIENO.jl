using Documenter
using QIENO

makedocs(
    sitename="QIENO.jl",
    authors="Ciprian Stefan Plesca",
    modules=[QIENO],
    format=Documenter.HTML(
        canonical="https://ciprian-localpulse.github.io/QIENO.jl/",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Theory" => "theory.md",
        "Tutorials" => "tutorials.md",
        "API Reference" => "API.md",
    ],
    warnonly=[:missing_docs],
)

deploydocs(repo="github.com/Ciprian-LocalPulse/QIENO.jl.git", devbranch="main")
