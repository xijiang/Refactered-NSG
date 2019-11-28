#!/usr/bin/env bash
if [ $# == 0 ]; then
    cat fnc/opts.txt
else
    echo preparing functions
    . fnc/parameters.sh `pwd`
    . fnc/functions.sh

    if [ ! -f $bin/ivcf-cmp ]; then
        cd $src
        make
        make mv
    fi
    cd $base

    case "$1" in
	bgl)
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
	    echo Fileter out SNP and ID obtained from q17
	    mkdir -p $a17k/flt
	    cd $a17k/flt
	    filter-id-snp
	    ;;
	#################### imputation
	i12)
	    echo Imputation from 8k to 17k
	    # using only the filtered data
	    ;;
	#################### Gmatrix
	gmt)
	    if [ $# != 5 ]; then
		echo
		grep gmt fnc/opts.txt
		exit 1
	    fi
	    source fnc/calc-g-mat.sh
	    calc-g $2 $3 $4 $5
	    ;;
	*)
            cat fnc/opts.txt
	    ;;
    esac
fi
