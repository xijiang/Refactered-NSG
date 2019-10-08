# Refactered-NSG
My refactored NSG codes
    
## Introduction
My codes with NSG NWS genomic selection project have reached to +4k lines.  It is time to organize them and using workflow to maintain, develop, and release these codes in a nicer manner.

Notes:
LD: 8k, 7327 loci
MD: 17k, 16227 loci
HD: 606k, 606006 loci

## Imputation
### Test imputation with MD (17k) chip data on LD(8k) to MD
This was done on `Fri 27 Sep 2019 03:59:27 PM CEST`.  Genotype error rates ~4%, correlation ~93%.
    
### Including ID genotyped with 606k 
1. Because this was selected to improve imputation

But,

1. only 13281 shared loci between 17k and 606k.  17k has 14974 autosomal loci.
2. The missing 1693 loci needs to be imputed back.
3. Check in the 345 ID, see if there are loci shared between 8k and 17k, but not between 17k and 606k, for imputation results.
4. Check if imputation in LD has been improved

## ToDo
* Construction of a G matrix with these data
* Cross-validation, 'genetic trend' test
* Paper about Ne
