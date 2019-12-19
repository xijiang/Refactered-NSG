# NAME
   run-pipeline.sh - a manual for Xijiang's NSG programs

# SYNOPSIS
   *./run-pipeline* option(s)

# DESCRIPTION
   *run-pipeline.sh* The scripts run several pipepines to merge genotypes, quality control, filtering and prepare **G** matrices for GEBV calculation.

# OPTIONS
  - Code preparation
    - *ver*: Showing the current version of Xijiang's codes
    - *update*: Download the latest release.  Also prepare binaries of my codes
  - Genotype manipulatiions
    - Dealing with genotypes with 8k chips
      - *m8k*: Merge the genotypes from 8k chips, into one VCF file.
      - *q8k*: Quality control of the created VCF file
      - *f8k*: Filter out ID and SNP, which you **must specify manually**.
    - Dealing with genotypes with 17k chips
      - *m17*: merge genotypes from 17k-alpha chips, into one VCF file
      - *q17*: quality control of the created VCF file
      - *f17*: filter out ID and SNP, which you **must specify manually**
      - *tlm*: test imputation from 8k to 17k.
    - Dealing with 17k beta genotypes
      - *b17*: convert the only file to vcf format
    - Dealing with genotypes with 606k chips
      - *m6d*: merge genotypes with 606k chips
      - *q6d*: quality control of elements in ID by SNP
      - *f6d*: filter out ID and SNP, which you **must specify manually**
  - Imputation and G calculation
    - *i+g*: imputation from **filtered** genotypes to **filtered** and **phased** genotypes
      - The job is dealed in $work/i+g, with command:
      - *./run-pipelin.sh i+g fra to rst [id-list]*
      - *i+g* is the option
      - *fra* is the filtered low density genotypes result
      - --- currently *fra* has two options: **8k** and **17k**
      - *to* is the filtered and phased reference genotypes of higher density.
      - --- currently *to* has two options: **17k** and **606k**
      - *rst* specify the result VCF file name, i.e., *rst*.vcf.gz. It will be over-written if exists.
      - *id-list* is optional, if specified, only use *id-list* for **G**. Or, all ID will be used
