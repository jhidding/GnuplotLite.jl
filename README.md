# GnuplotLite.jl
There currently are two bigger modules that interact with Gnuplot (`Gnuplot.jl` and `Gaston`). I don't like both of them, the reason being that they made the layering between Julia and Gnuplot too thick. When things don't work, I can't reason out why, even though I've used Gnuplot for over a decade. Even if `Gnuplot.jl` claims to be a thin wrapper, its code is over 2000 lines in a single file.

All I need is a command to start a Gnuplot instance, and send commands and data:

