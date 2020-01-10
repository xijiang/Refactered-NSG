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

make-qc-groups(){
    # This funciton will divide the ID into 20 or 21 groups.
    # If the 21st groups has less ID than the rest, it is removed
    # Then there will be 20 groups to be tested.
    
    nid=`wc id.lst | gawk '{print $1}'`
    let grpsz=$nid/$ngroups
    let ntest=$grpsz*$ngroups
    
    if [ -d tmp ]; then rm -rf tmp; fi
    for i in `seq -w $nrepeats`; do
	mkdir -p tmp/$i
	cd tmp/$i
	cat ../../id.lst |
	    shuf |
	    split -l $grpsz
	if [ $ntest -ne $nid ]; then
	    rm `ls x* | tail -1` # The last one is usually smaller than the rest
	fi
	cd -
    done
}

stride-on-snp(){
    msksnp=0
    for grp in x*; do
	echo
	date +%Z\ %F\ %T
	echo Dealing with file $grp
	zcat $qcd/../ori.vcf.gz |
	    $bin/vcf-by-id $grp |
	    $bin/msk-ith $msksnp $qcblksize |
	    gzip -c >msk.vcf.gz
	cat $grp $qcd/id.lst |
	    sort |
	    uniq -c |
	    gawk '{if($1==1) print $2}' >ref
	zcat $qcd/../ref.vcf.gz |
	    $bin/vcf-by-id ref |
	    gzip -c >ref.vcf.gz

	java -ea -Xmx3G -jar $bin/beagle.jar \
	     nthreads=$nthreads \
	     ref=ref.vcf.gz \
	     gt=msk.vcf.gz \
	     ne=$ne \
	     out=imp >/dev/null

	mv imp.log $grp.log

	zcat $qcd/../ref.vcf.gz |
	    $bin/vcf-by-id $grp |
	    $bin/extrgt imputed.snp >cmp.gt
	zcat imp.vcf.gz |
	    $bin/extrgt imputed.snp >imp.gt
	tar jcvf $qcd/rst/$1.$grp.tar.bz2 cmp.gt imp.gt $grp

	let msksnp=msksnp+1
	let msksnp=msksnp%$qcblksize
    done
}

qc-summarize(){
    cd rst

    if [ -f summary.txt ]; then rm summary.txt; fi
    if [ -f allsum.txt ]; then rm allsum.txt; fi

    for i in `seq -w $nrepeats`; do
	for j in $i.*.bz2; do
	    tar xvf $j
	    grp=`echo $j | gawk -F. '{print $2}'`
	    $bin/qc-2d cmp.gt imp.gt $grp >>summary.txt
	    rm cmp.gt imp.gt $grp
	done
	cat summary.txt |
	    $bin/qc-2d-sum
	mv ID.qc $i.ID.qc
	mv SNP.qc $i.SNP.qc
	cat summary.txt >> allsum.txt
	rm summary.txt
    done

    for i in `seq -w $nrepeats`; do
	cat $i.ID.qc |
	    sort -nk2 |
	    tail -20 >>rid.txt
	gawk '{if($2>.15) print $1}' $i.SNP.qc >>rsnp.txt
    done

    cat rid.txt |
	gawk '{print $1}' |
	sort |
	uniq -c |
	sort -nk1 >id.tab

    cat rsnp.txt |
	gawk '{print $1}' |
	sort |
	uniq -c |
	sort -nk1 >snp.tab

    cat allsum.txt |
	$bin/qc-2d-sum
    mv ID.qc overall-id.qc
    mv SNP.qc overall-snp.qc
    rm allsum.txt
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
    comm -23 <(sort ../qcd/id.lst)  <(sort exclude.id)  >keep.id
    comm -23 <(sort ../qcd/snp.lst) <(sort exclude.snp) >keep.snp
    
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
    echo Note: only exclude.snp will be created at this stage.
    echo If you have other ID and SNP to be excluded,
    echo you can append them to exclude.id and/or exclude.snp before this procedure.
    echo
    # And since current QC won't repeat on ID
    # below are disabled.  But no ID can be listed at the current stage anyway.
    # if [ -f ../qcd/rst/overall-id.qc ]; then
    #  	gawk '{if($2>.2) print $1}' ../qcd/rst/overall-id.qc >exclude.id
    # else
    # 	echo Have you run the QC pipeline?
    # fi
    
    if [ -f ../qcd/rst/overall-snp.qc ]; then
	gawk '{if($2>.15) print $1}' ../qcd/rst/overall-snp.qc >exclude.snp
    else
	echo Have you run the QC pipeline?
    fi
}

update-qc-history(){
    cd $work
    mkdir -p $hist
    for chip in 17k-alpha 8k 606k; do
	cd $chip/qcd/rst
	if [ -f ID.qc ]; then
	    sec=`stat -c %W ID.qc`
	    cp ID.qc $hist/$chip.$sec.ID
	fi
	if [ -f SNP.qc ]; then
	    sec=`stat -c %W ID.qc`
	    cp SNP.qc $hist/$chip.$sec.SNP
	fi
	cd -
    done
}

##^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
########################################
