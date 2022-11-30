# GnuplotLite.jl
Responsive, composable, no-nonsense interface to Gnuplot. This has the following design goals:

- Responsiveness: this should be the thinnest of possible wrappers. The biggest drag to plotting in Julia is the number of lines of code that sit in between the programmer and the plotter.
- Composability: it should be easy to extend GnuplotLite.
- Transparency: it should be easy to reason about how data is entered into Gnuplot.

That being said, there are so many plotting packages in Julia. When should you use this?

- Use `GnuplotLite` if you are in love with Gnuplot and want nothing to sit in between you and it.

```julia
using GnuplotLite

gnuplot() do gp
    gp |>
        send("set term svg background 'white'") |>
        send("set output 'sine.svg'") |>
        send("plot sin(x)")
end
```

You can specialize writing data to Gnuplot by overloading the `send()` method.

```julia
x = -4:0.15:4
y = x
z = sinc.(sqrt.(x.^2 .+ y'.^2))

gnuplot() do gp
    gp |>
        send("data" => (x=collect(x),y=collect(y),z=z)) |>
        send("plot \$data matrix nonuniform with image")
end
```

Check out the [full documentation](https://jhidding.github.io/GnuplotLite.jl).

## License
Copyright 2022, Johan Hidding, Netherlands eScience Center.

Licensed under the Apache 2.0 license, see LICENSE.

