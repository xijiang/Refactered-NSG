#!/usr/bin/env bash
if [ $# != 1 ]; then
    cat fnc/opts.txt
else
    echo preparing functions
    . fnc/parameters.sh
    . fnc/functions.sh

    if [ ! -f $bin/vcf-paste ]; then
        cd $src
        make
        make mv
    fi
    cd $base
    
    case "$1" in
	    17k|17K)
	        source fnc/17k-alpha.sh
	        calc-ga17k		# with genotype 17k alpha
	        ;;
	    lmr|LMR|Lmr)
	        source fnc/l2m-imputation.sh
            lmr
	        ;;
        6dk)
            source fnc/606k.sh
            e17k
            ;;
        *)
            cat fnc/opts.txt
            ;;
    esac
fi
