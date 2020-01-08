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
    - Dealing with 17k beta genotypes
      - *b17*: convert the only file to vcf format
    - Dealing with genotypes with 606k chips
      - *m6d*: merge genotypes with 606k chips
      - *q6d*: quality control of elements in ID by SNP
      - *f6d*: filter out ID and SNP, which you **must specify manually**
    - Backup all the QC history
      - *qch*: seach 17k-alpha, 8k, 606k for ID.qc and SNP.qc and back them up.
  - Imputation and G calculation
    - *i+g*: imputation from **filtered** genotypes to **filtered** and **phased** genotypes
    - currently, this will use 17k data as reference.
    - 17k-beta, HD and 8k data will be imputed to 17k level to calculate a G-matrix
