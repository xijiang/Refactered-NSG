i-n-g(){
    # Check files availability
    light=green
    for file in $lref $rinc; do
	if [ ! -f $file ]; then
	    light=red
	    echo $file is not ready
	fi
    done
    if [ $light == red ]; then
	echo $light
	echo Error: some files are not ready
	echo Please check fnc/parameters.sh to correct this
	return 1
    fi
    
    mkdir -p $wig
    cd $wig
    if [ -f $gmat ]; then
	echo $gmat will be overwritten
    fi

    # Merge files
    cp $lref gt.vcf.gz
    for file in $rinc; do
	$bin/ljvcf <(gunzip -c gt.vcf.gz) <(gunzip -c $file) |
	    gzip -c >tmp.vcf.gz
	mv tmp.vcf.gz gt.vcf.gz
    done
    
    java -ea -jar $bin/beagle.jar \
	 nthreads=$nthreads \
	 gt=gt.vcf.gz \
	 ne=$ne \
	 out=imp >/dev/null

    zcat imp.vcf.gz |
	head -30 |
	grep CHROM |
	tr '\t' '\n' |
	tail -n+10 > list.id

    zcat imp.vcf.gz |
	$bin/vcf2g |
	$bin/vr1g >G.mat

    cat G.mat |
	$bin/g2-3c list.id >$gmat
}
