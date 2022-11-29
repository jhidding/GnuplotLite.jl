push!(LOAD_PATH,"../src/")

using Documenter, GnuplotLite

makedocs(sitename="GnuplotLite documentation")
deploydocs(
    repo = "github.com/jhidding/GnuplotLite.jl.git",
)