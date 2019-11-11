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
	source $base/fnc/17k-alpha.sh
	prepare-17ka-dir
	impute-17ka-missing-gt
    fi
    if [ -d $QCD ]; then rm -rf $QCD; fi
    mkdir -p $QCD
    cd $QCD
}

get-ID-n-SNP() {
    zcat $a17k/imp/1.vcf.gz |
	grep CHROM |
	tr '\t' '\n' |
	tail -n+10 >17k.id
    echo 17k autosomal results and to v4
    zcat $a17k/pre/1.vcf.gz |
	grep \# >pre.vcf
    zcat $a17k/pre/{1..26}.vcf.gz |
	grep -v \# |
	$bin/to-v4 $maps/17k.v4 >>pre.vcf
    grep -v \# pre.vcf |
	$bin/vcf-stat >missing.stat
    grep -v \# pre.vcf |
	gawk '{print $3}' >17k.snp
    pigz pre.vcf
    
    # get the missing genotype statistics on ID and SNP.
    head -1 missing.stat |
	tr ' ' '\n' |
	tail -n+2 >tmp
    paste 17k.id tmp |
	sort -nk2 >missing.onid
    tail -1 missing.stat |
	tr ' ' '\n' |
	tail -n+2 >tmp
    paste 17k.snp tmp |
	sort -nk2 >missing.onsnp
    rm tmp
    
    # Perhaps where a locus is missing many genotypes is not very important
    # as they can be imputed back anyway.
    # But an ID missing many loci is not acceptable.

    java -jar $bin/beagle.jar \
	 gt=pre.vcf.gz \
	 ne=100 \
	 out=ref
}

qc-random-block(){
    # since NID = 4796 = 2*2*11*109, I will take 44 ID a group after shuffle the ID
    # then mask every 10th loci start from 0..9
    # in the end, every loci will be masked ~11 times
    # I will repeat the shuffle 5 times. e.g.,
    # every ID will be imputed on different loci 5 times.
    mkdir -p tmp rst
    cd tmp

    for rpt in {1..5}; do
	cat ../17k.id |
	    shuf |
	    split -l 44
	msk=0
	for grp in x*; do
	    zcat ../pre.vcf.gz |
		$bin/vcf-by-id $grp |
		$bin/msk-ith $msk 10 |
		gzip -c >msk.vcf.gz
	    cat $grp ../17k.id |
		sort |
		uniq -c |
		gawk '{if($1==1) print $2}' >ref
	    zcat ../ref.vcf.gz |
		$bin/vcf-by-id ref |
		gzip -c >ref.vcf.gz
	    java -jar $bin/beagle.jar \
		 ref=ref.vcf.gz \
		 gt=msk.vcf.gz \
		 ne=$ne \
		 out=imp

	    zcat ../ref.vcf.gz |
		$bin/vcf-by-id $grp |
		$bin/extrgt imputed.snp >cmp.gt
	    zcat imp.vcf.gz |
		$bin/extrgt imputed.snp >imp.gt
	    tar jcvf ../rst/$rpt.$grp.tar.bz2 cmp.gt cmp.gt $grp
	    let msk=msk+1
	    let msk=msk%10
	done
	rm x*
    done
}
quanlity-control() {
    prepare-data
    get-ID-n-SNP
    qc-random-block
}
