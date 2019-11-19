# get genotypes groups, e.g, G7327, G600k
base="$1"
ne=100

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

## 17k genotypes related
a17k=$work/17k-alpha

### Quality control
QCD=$a17k/qcd			# QCD: quality control directory
qcblksize=10
grpsize=44
qcrepeat=10

## Other
l2mT=$work/l2m-imputation-test
HDGT=$work/606k-related
