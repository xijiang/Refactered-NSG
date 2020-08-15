#!/usr/bin/env bash
echo preparing functions
. fnc/parameters.sh `pwd`
. fnc/functions.sh

if [ $# == 0 ]; then
    show-help fnc/alpha.md
else
    cd $base

    case "$1" in
	ver)
	    git describe --tags
	    ;;
	update)
	    rm -rf $bin
	    git pull
	    cd $src
	    make
	    make mv
	    get-beagle-related
	    ;;
	#################### 8k genotypes
	m8k)
	    source fnc/merge-8k-gt.sh
	    merge-8k-genotypes
	    ;;
	q8k)
	    source fnc/qc-8k-data.sh
	    quality-control-8k
	    ;;
	f8k)
	    echo Filter out SNP and ID obtained from q8k
	    mkdir -p $g8k/flt
	    cd $g8k/flt
	    exclude-list
	    filter-id-snp
	    ;;
	#################### 17k genotypes
	m17)
            source fnc/merge-17k-gt.sh
            merge-17k # with genotype 17k alpha
            ;;
	q17)
	    source fnc/qc-17k-data.sh
	    quality-control-17k
	    ;;
	f17)
	    echo Filter out SNP and ID obtained from q17
	    mkdir -p $a17k/flt
	    cd $a17k/flt
	    exclude-list
	    filter-id-snp
	    ;;
	#################### 17k beta genotypes
	b17)
	    source fnc/b17k-ss.sh
	    merge-17kb
	    ;;
	#################### imputation & G matrix
	i+g)
	    echo Merge and impute, result in a G matrix in 3-c format
	    source fnc/imputation+G.sh
	    i-n-g
	    ;;
	####################
	qch)
	    echo updating QC history
	    update-qc-history
	    ;;
	*)
	    show-help
	    ;;
    esac
fi
