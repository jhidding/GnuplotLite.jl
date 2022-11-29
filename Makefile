.PHONY: docs

docs:
	julia --project=docs/ -e 'using Pkg; Pkg.develop(PackageSpec(path=pwd())); Pkg.instantiate()'
	julia --compile=min -O0 --project=docs/ docs/make.jl
