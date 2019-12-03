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

##==============================================================================
## Quality control and filtering
##------------------------------------------------------------------------------
## 8k genotypes related
g8k=$work/8k

### Quality control
grpsz8k=50			# as 50*113 == 5650

##------------------------------------------------------------------------------
## 17k genotypes related
a17k=$work/17k-alpha

### Quality control
grpsz17k=44			# as 44*109 == 4796, the current n-ID

##------------------------------------------------------------------------------
## 606k genotypes related
g6dk=$work/606k

### quality control
grpsz6dk=23			# as 36*23 == 828

##==============================================================================
## Imputation and G calculation
wig=$work/i+g			# work directory for imputaion and G calculation

## Up to now, we have 3 classes of genotypes, i.e., 8k, 17k, and 606k
## Genotype files to be imputed
i8k=$g8k/flt/flt.vcf.gz
i17k=$a17k/flt/flt.vcf.gz

## Reference files
r17k=$a17k/flt/ref.vcf.gz
r6dk=$g6dk/flt/ref.vcf.gz

##==============================================================================
## Other
l2mT=$work/l2m-imputation-test
HDGT=$work/606k-related
