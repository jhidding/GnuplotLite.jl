module Script

using GnuplotLite
import GnuplotLite: send, Msg

struct QuadMesh{P2}
    vertices::Matrix{P2}
    colors::Matrix{Float64}
end

struct QuadMeshWireframe{P2}
    mesh::QuadMesh{P2}
end

wireframe(mesh::QuadMesh) = QuadMeshWireframe(mesh)

function send(mesh::Pair{String, QuadMesh{P2}}) where {P2}
    name, data = mesh
    n, m = size(data.vertices)
    v = data.vertices
    quads = [[v[i, j], v[i, j+1], v[i+1, j+1], v[i+1, j]]
             for i in 1:n-1, j in 1:m-1]

    return function (gp)
        gp |> send("\$$(name) << EOD")
        for (q, c) in zip(quads, data.colors)
            for v in q
                gp |> send("$(v[1]) $(v[2]) $(c)")
            end
            gp |> send("")
        end
        gp |> send("EOD")
    end |> Msg
end

function send(wireframe::Pair{String, QuadMeshWireframe{P2}}) where {P2}
    name, data = wireframe
    v = data.mesh.vertices

    return function (gp)
        gp |> send("\$$(name) << EOD")
        for r in eachrow(v)
            for v in r
                gp |> send("$(v[1]) $(v[2])")
            end
            gp |> send("")
        end

        for c in eachcol(v)
            for v in c
                gp |> send("$(v[1]) $(v[2])")
            end
            gp |> send("")
        end
        gp |> send("EOD")
    end |> Msg
end

function main()
    na = [CartesianIndex()]
    N = 20
    x = (1:N+1)[:, na] .+ 0.2 .* randn(N+1, N+1)
    y = (1:N+1)[na, :] .+ 0.2 .* randn(N+1, N+1)

    mesh = QuadMesh(tuple.(x, y), randn(N, N))

    gnuplot() do gp
        gp |> send("quads" => mesh)
        gp |> send("grid" => wireframe(mesh))
        gp |> send("plot \$quads with filledcurves closed lc palette, \\") |>
              send("     \$grid with lines lc 'black'")
        # gp |> send("plot \$data with lines lc 0")
    end
end

end

Script.main()

