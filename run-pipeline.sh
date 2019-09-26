#!/usr/bin/env bash
if [ $# != 1 ]; then
    cat fnc/opts.txt
else
    echo preparing functions
    . fnc/parameters.sh
    . fnc/functions.sh
    cd $src
    make
    make mv
    cd $base
    
    case "$1" in
	    17k|17K)
	        source fnc/17k-alpha.sh
	        calc-ga17k		# with genotype 17k alpha
	        ;;
	    lmr|LMR|Lmr)
	        source fnc/l2m-imputation.sh
            test-less2more
	        ;;
        *)
            cat fnc/opts.txt
            ;;
    esac
fi
