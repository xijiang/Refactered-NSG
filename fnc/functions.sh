# Get the latest Beagle
# -- Notice the name of nightly Beagle is like beagle.ddMMMyy.xyz.jar
# -- at the following URL
# -- So, I ordered them on yymmdd, and return the absolute address
# -- of the latest Beagle.
the-latest-beagle(){
    # Notice the name of nightly Beagle is like beagle.ddMMMyy.xyz.jar
    # at the following URL
    # So, I ordered them on yymmdd, and return the absolute address
    # of the latest Beagle.

    #echo -n https://faculty.washington.edu/browning/beagle/
    curl -sl https://faculty.washington.edu/browning/beagle/ |
        grep beagle.*jar |
        gawk -F\" '{print $6}' |
        gawk -F\. '{if(NF==4) print $0}' |
        $bin/latest-beagle
}


get-beagle-related(){
    beagle=`the-latest-beagle`
    echo Current version $beagle
    mkdir -p $bin
    cd $bin
    if [ ! -f $beagle ]; then
	curl https://faculty.washington.edu/browning/beagle/$beagle -o $beagle
    fi
    
    if [ -f beagle.jar ]; then rm -f beagle.jar; fi
    ln -s $beagle beagle.jar

    if [ ! -f beagle2vcf.jar ]; then
    	wget https://faculty.washington.edu/browning/beagle_utilities/beagle2vcf.jar
    fi
    
    cd $base
}

show-help(){
    required="pandoc most pigz"
    for prg in $requred; do
	if [ ! -x command -v $prg ]; then
	    echo Please install $prg
	fi
    done
    pandoc -st man fnc/opts.md |
	groff -T utf8 -man |
	most
}

########################################
## Functions for quality control
##--------------------------------------
general-statisitcs(){		# on missing data
    echo Basic statistics on data missing.
    echo This is done in `pwd`
    echo Who are in the file
    zcat ../ori.vcf.gz |
	grep CHROM |
	tr '\t' '\n' |
	tail -n+10 >id.lst
    echo What are the loci
    zcat ../ori.vcf.gz |
	\grep -v \# |
	gawk '{print $3}' >snp.lst
    zcat ../ori.vcf.gz |
	grep -v \# |
	$bin/vcf-stat >ori.stat
    head -1 ori.stat |
	tr ' ' '\n' |
	tail -n+2 >tmp
    paste id.lst tmp |
	sort -nk2 >onid.missing
    tail -1 ori.stat |
	tr ' ' '\n' |
	tail -n+2 >tmp
    paste snp.lst tmp |
	sort -nk2 >onsnp.missing
    rm tmp
}


stride-on-snp(){
    if [ -d tmp ]; then rm -rf tmp; fi
    mkdir -p tmp
    cd tmp
    cat ../id.lst |
	shuf |
	split -l $1		# on group size

    msksnp=0
    for grp in x*; do
	echo
	echo Dealing with file $grp
	zcat ../../ori.vcf.gz |
	    $bin/vcf-by-id $grp |
	    $bin/msk-ith $msksnp $qcblksize |
	    gzip -c >msk.vcf.gz
	cat $grp ../id.lst |
	    sort |
	    uniq -c |
	    gawk '{if($1==1) print $2}' >ref
	zcat ../../ref.vcf.gz |
	    $bin/vcf-by-id ref |
	    gzip -c >ref.vcf.gz

	java -ea -Xmx3G -jar $bin/beagle.jar \
	     ref=ref.vcf.gz \
	     gt=msk.vcf.gz \
	     ne=$ne \
	     out=imp

	zcat ../../ref.vcf.gz |
	    $bin/vcf-by-id $grp |
	    $bin/extrgt imputed.snp >cmp.gt
	zcat imp.vcf.gz |
	    $bin/extrgt imputed.snp >imp.gt
	tar jcvf ../rst/$grp.tar.bz2 cmp.gt imp.gt $grp

	let msksnp=msksnp+1
	let msksnp=msksnp%$qcblksize
    done
}

qc-summarize(){
    cd rst
    if [ -f summary.txt ]; then rm summary.txt; fi
    for i in *bz2; do
	tar xvf $i
	grp=`echo $i | gawk -F. '{print $1}'`
	$bin/qc-2d cmp.gt imp.gt $grp >>summary.txt
	rm cmp.gt imp.gt $grp
    done

    cat summary.txt | $bin/qc-2d-sum
}

filter-id-snp(){
    if [ ! -f exclude.snp ] && [ ! -f exclude.id ]; then
	echo
	echo Error: exclude.snp and/or exclude.id not found
	echo Info : Refer to my documentation
	echo
	return 1
    fi

    touch exclude.{snp,id}	# empty if not specified before
    cat ../qcd/id.lst exclude.id |
	sort |
	uniq -c |
	gawk '{if($1==1) print $2}' >keep.id
    cat ../qcd/snp.lst exclude.snp |
	sort |
	uniq -c |
	gawk '{if($1==1) print $2}' >keep.snp
    
    zcat ../ori.vcf.gz |
	$bin/vcf-by-id keep.id |
	$bin/vcf-by-loci keep.snp |
	gzip -c >flt.vcf.gz
    echo The filtered results are stored in flt.vcf.gz
    
    java -jar $bin/beagle.jar \
	 gt=flt.vcf.gz \
	 ne=$ne \
	 out=ref >beagle.log
    echo The filtered and phased results are stored in ref.vcf.gz
}

exclude-list(){
    echo
    echo Note: exclude.id and exclude.snp will be created.
    echo If you have other ID and SNP to be excluded,
    echo you have to specify them before this procedure.
    echo 
    if [ -f ../qcd/rst/ID.qc ]; then
	sort -nk2 ../qcd/rst/ID.qc |
	    gawk '{if($2>.2) print $1}' >>exclude.id
    else
	echo Have you run the QC pipeline?
    fi
    if [ -f ../qcd/rst/SNP.qc ]; then
	sort -nk2 ../qcd/rst/SNP.qc |
	    gawk '{if($2>.15) print $1}' >>exclude.snp
    else
	echo Have you run the QC pipeline?
    fi
done

##^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
########################################
