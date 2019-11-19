# There might be some ID whose genotypes are just weird
# Here, I test the ID genotyped with 17k chips one-by-one.
# I mask their every fourth locus, and then impute them back.
# In four round, every locus was masked and imputed back once.
# I then calculate the genotype imputation errors
# and then rank all the ID according to these errors
# Currently I run this for physical map version 3
# But This will be a general test procedure, and should work smoothly on version 4.

prepare-data() {
    if [ ! -d $a17k ]; then
	source $base/fnc/merge-17k-gt-in-design-format.sh
	merge-17k
    fi
    if [ -d $QCD ]; then rm -rf $QCD; fi
    mkdir -p $QCD/rst
    cd $a17k
    if [ ! -f ref.vcf.gz ]; then
	java -jar $bin/beagle.jar \
	     nthreads=4 \
	     gt=ori.vcf.gz \
	     ne=$ne \
	     out=ref
    fi
}

general-statisitcs(){
    cd $QCD
    echo Basic statistics of data missing.
    echo Who are in the file
    zcat ../ori.vcf.gz |
	grep CHROM |
	tr '\t' '\n' |
	tail -n+10 >17k.id
    echo What are the loci
    zcat ../ori.vcf.gz |
	\grep -v \# |
	gawk '{print $3}' >17k.snp
    zcat ../ori.vcf.gz |
	grep -v \# |
	$bin/vcf-stat >ori.stat
    head -1 ori.stat |
	tr ' ' '\n' |
	tail -n+2 >tmp
    paste 17k.id tmp |
	sort -nk2 >onid.missing
    tail -1 ori.stat |
	tr ' ' '\n' |
	tail -n+2 >tmp
    paste 17k.snp tmp |
	sort -nk2 >onsnp.missing
    rm tmp
}

stride-on-snp(){
    # since NID = 4796 = 2*2*11*109, I will take 44 ID a group after shuffle the ID
    # then mask every 10th loci start from 0..9
    # in the end, every loci will be masked ~11 times
    # I will repeat the shuffle 5 times. e.g.,
    # every ID will be imputed on different loci 5 times.
    cd $QCD
    
    for rpt in {0..9}; do
	cd $QCD
	
	echo Thread $rpt has been sent to background
	$func/stride-on-snp.sh $rpt $base >/dev/null &
    done
    wait
}

hardy-weinberg-test(){
    echo Hardy-Weinberg test
    cd $QCD
    # Convert vcf to table
    # using Julia for the HW test
}

qc-summarize(){
    echo ToDo: summarize the results.
    # I will summarize the results into a table
    # each element is (error times)/(imputed times)
    # read the results into Julia DataFrames
    # Plot the ordered results
    # the last few points will show how bad an ID or SNP can be
}


quality-control-17k(){
    prepare-data
    general-statisitcs
    stride-on-snp
}


qc-debug(){
    cd $QCD
    rm -rf rst *tmp
    
    mkdir rst tmp
    cd tmp
    qc-one-repeat 1
}
