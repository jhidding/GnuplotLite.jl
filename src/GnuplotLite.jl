module GnuplotLite

export gnuplot, send, save

"""     struct Gnuplot

This `struct` is not exported, as it is not supposed to be created by a user,
other than through calling [`gnuplot()`](@ref), or [`save()`](@ref).

Messages can be sent to a Gnuplot instance using the [`send()`](@ref) method:

```julia
gnuplot() do g
    g |> send("plot sin(x)")
end
```
"""
struct Gnuplot
    channel :: Channel{String};
end

"""     struct Msg

This wraps the actions that are created using the different variants of the
[`send()`](@ref) method.

Messages can be composed (unlike `∘`, going left to right) using the `*`
operator.
"""
struct Msg
    action :: Function
end

(a::Msg)(g::Gnuplot) = a.action(g)
Base.:*(a::Msg, b::Msg) = Msg(b.action ∘ a.action)

"""
    gnuplot(persist = true, echo = false)

The main constructor for a `Gnuplot` instance. This starts the `gnuplot`
process and creates a channel to which commands can be sent.

The `persist` argument make sure that any interactive window remains open, even
if we have closed the pipe to the Gnuplot process.

The `echo` argument is for debugging. If enabled, all commands send to this
instance are also echoed to `stdout`.
"""
function gnuplot(;persist::Bool = true, echo::Bool = false)
    cmd = persist ? `gnuplot -persist` : `gnuplot`
    channel = Channel{String}() do channel
        open(cmd, stdout; write=true) do input
            for line in channel
                echo && println("> ", line)
                write(input, line * "\n")
            end
        end
    end
    Gnuplot(channel)
end

"""     close(::Gnuplot)

Close the Gnuplot process by closing the underlying channel. The actual process
my continue living if terminals are left open.
"""
Base.close(g::Gnuplot) = close(g.channel)

"""     gnuplot(::Function; kwargs...)

Variant of the `gnuplot` constructor for use with `do` syntax. Makes sure to
close the channel (and thereby) the process.
"""
function gnuplot(f::Function; kwargs...)
    g = gnuplot(kwargs...)
    f(g)
    close(g.channel)
end

"""     send(::String)

Send a literal message to a Gnuplot instance. This is supposed
to be used using a pipe (`|>`) operator.

Returns a [`Msg`](@ref).
"""
function send(msg::String)
    function (g::Gnuplot)
        put!(g.channel, msg)
        g
    end |> Msg
end

"""     send(::Pair{String,Matrix{T}}) where T <: Number

Send a matrix to Gnuplot, storing it in a variable. This variant assumes the
matrix gets integer indices from `[0..N-1]`, as described in the Gnuplot
documentation for uniform matrices.

Returns a [`Msg`](@ref).
"""
function send(data::Pair{String,Matrix{T}}) where
    {T <: Number}
    function (g::Gnuplot)
        g |> send("\$$(data[1]) << EOD")
        for row in eachrow(data[2])
            g |> send(join(string.(row), " "))
        end
        g |> send("EOD")
    end |> Msg
end

"""     send(::Pair{String,@NamedTuple{x::T,y::T,z::U}}) where
        {T <: AbstractVector{<:Real}, U <: AbstractMatrix{<:Real}}

Send a matrix to Gnuplot, storing it in a variable. This variant also sends
axis information along with the matrix, as described in the Gnuplot
documentation for nonuniform matrices.

Returns a [`Msg`](@ref).

Example:

        x = y = -1:0.1:1
        z = x.^2 .- y'.^2
        gnuplot() do gp
            gp |> 
                send("data" => (x=collect(x), y=collect(y), z=z)) |>
                send("splot \$data w l")
        end
"""
function send(data::Pair{String,@NamedTuple{x::T,y::T,z::U}}) where
    {T <: AbstractVector{<:Real}, U <: AbstractMatrix{<:Real}}
    (k, (x, y, z)) = data
    function (g::Gnuplot)
        g |> 
            send("\$$k << EOD") |>
            send("$(length(x)) $(join(string.(x), " "))")
        for (y, row) in zip(y, eachrow(z))
            g |> send("$y $(join(string.(row), " "))")
        end
        g |> send("EOD")
    end |> Msg
end

"""     save(path::String)

Create a phony [`Gnuplot`](@ref) instance, without the underlying process
attached. Instead, write messages to file. You can then later turn the file
into a plot by running it with Gnuplot from the command line, or run a
`pipeline` from Julia.
"""
function save(path::String)
    channel = Channel() do channel
        open(path, "w") do output
            for line in channel
                write(output, line * "\n")
            end
        end
    end
    Gnuplot(channel)
end

end # module
