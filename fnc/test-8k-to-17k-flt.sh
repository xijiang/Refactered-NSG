# This is to test imputation error rate before and after filtering.
# Error rates on individual SNP are also reported.
prepare-tlm(){
    if [ ! -f $a17k/ori.vcf.gz ]; then
	echo $a17k/ori.vcf.gz is needed for this test
	return 1
    fi
    
    if [ ! -f $i17k ]; then
	echo $i17k is needed
	return 2
    fi

    if [ ! -f $g8k/ori.vcf.gz ]; then
	echo $g8k/ori.vcf.gz is needed to trace SNP it contains
	return 3
    fi
    
    tlm=$a17k/tlm
    if [ ! -d $tlm ]; then mkdir -p $tlm; fi

    zcat $g8k/ori.vcf.gz |
	grep -v \# |
	gawk '{print $3}' >$tlm/8k.snp
}

id-n-snp(){
    # all ID
    zcat $1 |
	grep CHROM |
	tr '\t' '\n' |
	tail -n+10 >all.id
    # shared SNP
    zcat $1 |
	grep -v \# |
	gawk '{print $3}' >17k.snp
    cat 8k.snp 17k.snp |
	sort |
	uniq -c |
	gawk '{if($1==2) print $2}' >shared.snp
    cat shared.snp 17k.snp |
	sort |
	uniq -c |
	gawk '{if($1==1) print $2}' >imputed.snp
}

msk-n-imp(){
    cat all.id |
	shuf |
	head -n $refsz >ref.id
    cat all.id ref.id |
	sort |
	uniq -c |
	gawk '{if($1==1) print $2}' >msk.id
    zcat $1 |
    	$bin/vcf-by-id ref.id |
    	gzip -c >ori.vcf.gz
    java -ea -jar $bin/beagle.jar \
    	 gt=ori.vcf.gz \
    	 ne=$ne \
    	 out=ref
    zcat $1 |
    	$bin/vcf-by-id msk.id |
	$bin/mskloci shared.snp |
    	gzip -c >msk.vcf.gz
    java -ea -jar $bin/beagle.jar \
    	 ref=ref.vcf.gz \
    	 gt=msk.vcf.gz \
    	 ne=$ne \
	 out=imp
    zcat $2 |
    	$bin/vcf-by-id msk.id |
    	$bin/extrgt imputed.snp >cmp.gt
    zcat imp.vcf.gz |
    	$bin/extrgt imputed.snp >imp.gt
    tar jcvf $3.tar.bz2 {cmp,imp}.gt
}

tlm-summary(){
    mkdir -p $tlm/tmp
    cd $tlm/tmp
	
    for tst in o f; do
	for i in $repeats; do
	    tar xvf ../$tst.$i.tar.bz2
	    paste {cmp,imp}.gt |
		$bin/tlh-cmp > $i.txt
	    wc *.gt
	    rm *.gt
	done
	for i in $repeats; do
	    cat $i.txt
	done |
	    $bin/tlh.sum >$tst.sum 2>$tst.mean
    done
}

tlm-procedure(){
    cd $tlm
    ########################################
    ## Test all available ID and SNP
    id-n-snp $a17k/ori.vcf.gz
    for rpt in $repeats; do
    	msk-n-imp $a17k/ori.vcf.gz $a17k/ref.vcf.gz o.$rpt
    done
    
    ## Test filtered results
    id-n-snp $a17k/flt/flt.vcf.gz
    for rpt in $repeats; do
    	msk-n-imp $a17k/flt/flt.vcf.gz $a17k/flt/ref.vcf.gz f.$rpt
    done
}

test-tlm(){
    cd $tlm
    id-n-snp $a17k/flt/flt.vcf.gz
    for rpt in $repeats; do
    	msk-n-imp $a17k/flt/flt.vcf.gz $a17k/flt/ref.vcf.gz f.$rpt
    done
}

tlm-driver(){
    repeats=`seq 0 9`
    
    prepare-tlm
    
    tlm-procedure
    
    tlm-summary
}
