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
qcblksize=10			# this usually doesn't need change

#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
## Don't touch above
########################################

## 17k genotypes related
a17k=$work/17k-alpha

### Quality control
grpsz17k=44			# as 44*109 == 4796, the current n-ID

## 8k genotypes related
g8k=$work/8k

### Quality control
grpsz8k=50			# as 50*113 == 5650

## Other
l2mT=$work/l2m-imputation-test
HDGT=$work/606k-related
