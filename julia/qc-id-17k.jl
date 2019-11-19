#!/usr/bin/env julia
using DelimitedFiles, Random
base = ARGS[1]

# Determine groups
id = readdlm("17k.id", String)[:, 1]
allid = Set{String}(id)
ngrp = 60        # n-groups

# Set group size
group = repeat([length(id) ÷ ngrp], ngrp)
for  i in 1:length(id)-group[ngrp]*ngrp
    group[i] += 1
end 

shuffle!(id)
beg = 1
for i in 1:ngrp
    global beg
    msk = Set{String}(id[beg:beg+group[i]-1])
    beg = beg + group[i]
    ref = setdiff(allid, msk)
    writedlm("msk.id", msk)
    writedlm("ref.id", ref)
    run(pipeline(`zcat imp.vcf.gz`,
                 `$base/bin/vcf-by-id ref.id`,
                 `gzip -c >ref.vcf.gz`))
    run(pipeline(`zcat imp.vcf.gz`,
                 `$base/bin/vcf-by-id msk.id`,
                 `gzip -c >cmp.vcf.gz`))
    msk = i - 1
    run(pipeline(`zcat pre.vcf.gz`,
                 `$base/bin/vcf-by-id msk.id`,
                 `$base/bin/msk-eth $msk $ngrp`,
                 `gzip -c >msk.vcf.gz`))
    run(`java -jar $base/bin/beagle.jar ref=ref.vcf.gz gt=msk.vcf.gz ne=100 out=tst`)
    # ToDo
    # extract relevant loci of cmp and imp, and compare
end
