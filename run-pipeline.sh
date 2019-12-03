#!/usr/bin/env bash
echo preparing functions
. fnc/parameters.sh `pwd`
. fnc/functions.sh

if [ $# == 0 ]; then
    show-help
else

    if [ ! -f $bin/ljvcf ]; then
        cd $src
        make
        make mv
    fi
    cd $base

    case "$1" in
	ver)
	    git branch
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
	    filter-id-snp
	    ;;
	#################### 606k genotypes
	m6d)
	    source fnc/merge-606k-gt.sh
	    merge-6dk-genotypes
	    ;;
	q6d)
	    source fnc/qc-6dk-data.sh
	    quality-control-6dk
	    ;;
	f6d)
	    echo Filter out SNP and ID obtained from q6d
	    mkdir -p $g6dk/flt
	    cd $g6dk
	    ;;
	#################### imputation & G matrix
	i+g)
	    echo Imputation from low to high and calculate G
	    if [ $# == 4 ] || [ $# == 5 ]; then
		source fnc/imputation+G.sh

		if [ $# == 4 ]; then
		    i-n-g $2 $3 $4
		else
		    i-n-g $2 $3 $4 $5
		fi
	    else
		show-help
		exit 1
	    fi
	    
	    # using only the filtered data
	    ;;
	*)
	    show-help
	    ;;
    esac
fi
