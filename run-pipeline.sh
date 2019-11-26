#!/usr/bin/env bash
if [ $# != 1 ]; then
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
	m17)
            source fnc/merge-17k-gt-in-design-format.sh
            merge-17k # with genotype 17k alpha
            ;;
	q17)
	    source fnc/qc-17k-data.sh
	    quality-control-17k
	    ;;
	f17)
	    echo Fileter out SNP and ID obtained from q17
	    source fnc/filter-id-snp.sh
	    filter-id-snp
	    ;;
	m8k)
	    source fnc/
#	lmr | LMR | Lmr)
#            source fnc/l2m-imputation.sh
#            lmr
#            ;;
#	6dk)
#            source fnc/606k.sh
#            e17k
#            ;;
#	v34)
#            source fnc/v3-vs-v4.sh
#            new-lmr
#            ;;
#	8vr)
#            source fnc/8d-vs-random.sh
#            8d-v-ran-lmr
#            ;;
#	6vr)
#            source fnc/nws-hd.sh
#            6d-v-ran-lmr
#            ;;
#	qcd)
#            source fnc/qc-17k-id.sh
#            quanlity-control
#	    #qc-debug
#            ;;
	*)
            cat fnc/opts.txt
	    ;;
    esac
fi
