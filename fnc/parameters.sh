# get genotypes groups, e.g, G7327, G600k
base="$1"
ne=100

########################################
## Don't touch below
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# source codes
func=$base/fnc
src=$base/src
bin=$base/bin
julia=$base/julia

# raw data
dat=$base/data
genotypes=$dat/genotypes
phenotypes=$dat/phenotypes
maps=$dat/maps
ids=$dat/ids

# work dir
work=$base/work

#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
## Don't touch above
########################################

## 17k genotypes related
a17k=$work/17k-alpha

### Quality control
QCD=$a17k/qcd			# QCD: quality control directory
qcblksize=10			# this usually doesn't need change
grpsize=44			# as 44*109 == 4796, the current n-ID
#qcrepeat=5			# I have 24 threads 5 x 4 < 24
#qcthread=4			# 4 x 5 < 24 as in above line

## 8k genotypes related
g8k=$work/8k

### Quality control
q8k=$g8k/qcd


## Other
l2mT=$work/l2m-imputation-test
HDGT=$work/606k-related
