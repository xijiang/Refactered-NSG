#!/usr/bin/env julia
#=
This is a general test about the imputation rate from LD-7k to MD-17k.
I randomly sampled 50 ID to mask loci that are on 17k, but not on 7k.
Then I used the resot of the 4,796 ID as refererence.
=#

using DelimitedFiles, Plots, Statistics
dat = readdlm("num.txt")
dat = reshape(dat, 2, :)'
n = length(dat[:, 1])
ave = mean(dat[:, 1])

plot(dat[:, 1], label="Error rates", dpi=300)
plot!([1, n], [ave, ave], label="Mean error rates", ylabel="Error rate", dpi=300)

savefig("fix-2-fix.png")
