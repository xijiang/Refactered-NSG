filter-id-snp(){
    flt=$a17k/flt
    
    if [ ! -f $flt/exclude.snp ] && [ ! -f $flt/exclude.id ]; then
	echo
	echo Error: exclude.snp and/or exclude.id not found
	echo Info : Refer to my documentation
	echo
	return 1
    fi

    cd $flt

    touch exclude.{snp,id}	# empty if not specified before
    cat ../qcd/17k.id exclude.id |
	sort |
	uniq -c |
	gawk '{if($1==1) print $2}' >keep.id
    cat ../qcd/17k.snp exclude.snp |
	sort |
	uniq -c |
	gawk '{if($1==1) print $2}' >keep.snp
    
    zcat ../ori.vcf.gz |
	$bin/vcf-by-id keep.id |
	$bin/vcf-by-loci keep.snp |
	gzip -c >flt.vcf.gz
    echo The filtered results are stored in $flt/flt.vcf.gz
    
    java -jar $bin/beagle.jar \
	 gt=flt.vcf.gz \
	 ne=$ne \
	 out=ref >beagle.log
    echo The filtered and phased results are stored in $flt/ref.vcf.gz
}
