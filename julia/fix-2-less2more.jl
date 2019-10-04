#!/usr/bin/env julia
#=
This is to use a fixed set of ID as reference, and then sample more and more ID
from the rest to mask, and then to impute them back. The purpose is to test what
happes if a lot more ID are masked.
=#

using DelimitedFiles, Plots, Statistics
dat = readdlm("num.txt")
dat = reshape(dat, 2, :)'
n = length(dat[:, 1])

x=50:100:1950
plot(x, dat[:, 1],
     xlabel="Masked set size",
     label="Error rates",
     dpi=300,
     ylabel="Error rates",
     leg=false)

savefig("fix-2-less2more.png")
