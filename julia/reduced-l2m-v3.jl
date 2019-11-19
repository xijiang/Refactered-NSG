#!/usr/bin/env julia
#=
Using 17k map and the reduced set of loci, randomly select 1000 ID as reference
and randomly select 50 ID to mask. Them impute them back and check error rates.

This used 4,796 17k data.
=#

using DelimitedFiles, Plots, Statistics
dat = readdlm("num.txt")
dat = reshape(dat, 2, :)'
n = length(dat[:, 1])
ave = mean(dat[:, 1])

plot(dat[:, 1], label="Error rates", dpi=300)
plot!([1, n], [ave, ave], label="Mean error rates", ylabel="Error rate", dpi=300)

savefig("reduced-l2m-v3.png")
