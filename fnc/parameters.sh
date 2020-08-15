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
qcblksize=8			# this usually doesn't need change
hist=$work/log			# store ID and SNP that failed QC in history

#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
## Don't touch above
########################################

##==============================================================================
## Quality control and filtering
##------------------------------------------------------------------------------
nthreads=20
nrepeats=20
ngroups=8			# for quality control

## 8k genotypes related
g8k=$work/8k

### Quality control
grpsz8k=54			# as 50*113 == 5650

##------------------------------------------------------------------------------
## 17k genotypes related
a17k=$work/17k-alpha

### Quality control
grpsz17k=51			# before 44*109 == 4796. now 51x108.=5503
refsz=4000			# use 4000 ID as reference to impute masked rest

##------------------------------------------------------------------------------
## 17k beta data
b17k=$work/beta-17k

##------------------------------------------------------------------------------
## 606k genotypes related
g6dk=$work/606k

### quality control
grpsz6dk=12			# as 792 = 12x66

##==============================================================================
## Imputation and G calculation
wig=$work/i+g			# work directory for imputaion and G calculation

## We have 4 classes of genotypes to date: 8k, 17k-alpha, 17k-beta, and 606k
## Genotype files to be imputed
i8k=$g8k/ori.vcf.gz		# QC is removing too many ID and SNP
i17b=$b17k/ori.vcf.gz		# not filtered
i6dk=$g6dk/ori.vcf.gz		# can modify this to a filtered one

## Reference files
#-- remove '/flt' away for unfiltered genotype file
r17k=$a17k/flt/ref.vcf.gz

##------------------------------------------------------------------------------
## Specify files to be used for a big G matrix
lref=$r17k			# the left most reference file
rinc="$i17b $i6dk $i8k"		# these will be left joined to above

gmat="bigg.3c"

##==============================================================================
## Other
l2mT=$work/l2m-imputation-test
HDGT=$work/606k-related
