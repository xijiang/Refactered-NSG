#!/usr/bin/env julia
using Plots
#=
This is to plot the results about the imputation results with HD genotypes
I also take this chance to practise using Julia instead of bash for
scripting.
=#
only = "828-only"
vran = "inc8d-vs-random"
ext8 = "extra-8d-vs-random"

#= Figure 1:
Randomly sample 50 ID to be masked
Impute them back with:
    1. 828 data
    2. random 828 from 17k data
and compare
=#
rst = read(pipeline(`grep error $only/rates`,
                    `gawk '{print $NF}'`), String)
dat = reshape([parse(Float64, x) for x in split(rst)], 2, :)'

plot(dat,
     label=["Random", "data 828"],
     dpi=300,
     xlabel="Repeat",
     ylabel="Error rate",
     legend=:left)

savefig("828-vs-ran.png")


#= Figure 2:
Randomly sample 50 ID to be masked
Impute them back with

1. 828+extr random ID as reference
2. the above number of random ID from 17k data as reference

Impute and compare
=#
rst = read(pipeline(`grep error $vran/rates`,
                    `gawk '{print $NF}'`), String)
dat = reshape([parse(Float64, x) for x in split(rst)], 2, :)'
nid = 50+828:200:1500+828

plot(nid, dat,
     label=["Random", "828+(nran-828)"],
     dpi=300,
     xlabel="Reference set size",
     ylabel="Error rate")

savefig("inc828-vs-ran.png")

#= Figure 3:
Randomly sample 50 ID to be masked
Impute them back with

1. random select ID from 17k data
2. using above, plus 828 extra

Imputed and compare
=#
rst = read(pipeline(`grep error $ext8/rates`,
                    `gawk '{print $NF}'`), String)
dat = reshape([parse(Float64, x) for x in split(rst)], 2, :)'
nid = 1000:100:1500

plot(nid, dat,
     label=["Random", "Random + extr 828"],
     dpi=300,
     xlabel="Random set size, (the other has extra 828ID)",
     ylabel="Error rate",
     legend=:bottom)

savefig("inc828-vs-ran.png")
