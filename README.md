# Refactered-NSG
My refactored NSG codes
    
## Introduction
My codes with NSG NWS genomic selection project have reached to +4k lines.  It is time to organize them and using workflow to maintain, develop, and release these codes in a nicer manner.

## Imputation
### Test imputation with MD (17k) chip data on LD(8k) to MD
This was done on `Fri 27 Sep 2019 03:59:27 PM CEST`.  Genotype error rates ~4%, correlation ~93%.
    
### Including ID genotyped with 606k 

2. Impute current LD data to MD level
3. Construction of a G matrix with these data
4. Cross-validation, 'genetic trend' test
