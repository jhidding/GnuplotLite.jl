# GnuplotLite.jl
Responsive, composable, no-nonsense interface to Gnuplot.

```julia
using GnuplotLite

gnuplot() do gp
    gp |>
        send("set term svg background 'white'") |>
        send("set output 'sine.svg'") |>
        send("plot sin(x)")
end
```

Check out the [full documentation](https://jhidding.github.io/GnuplotLite.jl).

## License
Copyright 2022, Johan Hidding, Netherlands eScience Center
Licensed under the Apache 2.0 license, see LICENSE.

