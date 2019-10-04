#!/usr/bin/env julia
#=
This is to test Beagle usage.
When imputing, Beagle can either take two separate files, one as reference,
and the other as genotype file to be imputed. Or, these two files can be
merged as one as the genotype file.

Here I used the 4,796 ID who were genotyped with 17k chips.  Randomly sample
100 ID to be masked, using the rest as reference.
=#

using DelimitedFiles, Plots, Statistics
dat = readdlm("num.txt")
dat = reshape(dat, 4, :)'
n = length(dat[:, 1])
mtwo = mean(dat[:, 1])
mone=mean(dat[:,3])

plot(dat[:, 1], label="Two", dpi=300)
plot!([1, n], [mtwo, mtwo], label="Mean two", dpi=300)
plot!(dat[:, 3], label="One", dpi=300)
plot!([1, n], [mone, mone], label="Mean one", dpi=300)

savefig("one-vs-two.png")
