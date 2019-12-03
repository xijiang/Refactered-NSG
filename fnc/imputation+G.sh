i-n-g(){
    mkdir -p $wig
    cd $wig
    
    ########################################
    ## Check the arguments
    if [ $1 == $2 ]; then
	echo Please specify genotypes of either lower than $1 or higher than $2 in density.
	exit 3
    fi
    
    case "$1" in
	8k)
	    fra=$i8k
	    ;;
	17k)
	    fra=$i17k
	    ;;
	*)
	    echo I do not know what you are asking.
    esac

    if [ ! -f "$fra" ]; then
	echo You have to prepare genotype file $fra first to do such imputation
	return 1
    fi
    
    case "$2" in
	17k)
	    to=$r17k
	    ;;
	606k)
	    to=$r6dk
	    ;;
	*)
	    echo I do not know what you are asking.
    esac
    
    if [ ! -f "$to" ]; then
	echo You have to prepare reference file $to first to do such imputation
	return 2
    fi

    if [ -f $wig/$rst.vcf.gz ]; then
	echo Warning, $rst.vcf.gz will be overwritten.
    fi

    ########################################
    ## Imputation
    $bin/ljvcf <(gunzip -c $to) <(gunzip -c $fra) |
	gzip -c > tmp.vcf.gz
    java -ea -jar $bin/beagle.jar \
	 gt=tmp.vcf.gz \
	 ne=$ne \
	 out=$3

    if [ -f g.vcf.gz ]; then rm -f g.vcf.gz; fi

    if [ $# == 4 ]; then
	zcat $3.vcf.gz |
	    $bin/vcf-by-id $4 |
	    gzip -c >g.vcf.gz
    else
	ln -s $3.vcf.gz g.vcf.gz
    fi


    ########################################
    ## Calculate G matrix
    zcat g.vcf.gz |
	$bin/vcf2g |
	$bin/vr1g >$3.G

    zcat g.vcf.gz |
	head -30 |
	grep CHROM |
	tr '\t' '\n' |
	tail -n+10 >$3.id
    cat $3.G |
	$bin/g2-3c $3.id >$3.3c
}
