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
	split -l 240 -d 17k.id
	zcat $a17k/pre/{1..26}.vcf.gz |
		grep -v \# |
		gawk '{print $3}' >17k.snp
	# get the missing genotype statistics on ID and SNP.
	zcat $a17k/pre/{1..26}.vcf.gz |
		grep -v \# |
		$bin/vcf-stat >missing.stat
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
}

qc-on-id() {
	# now do the imputation test for quality
	# window=200 is critical here for speed.  It affect memory usage according to the manual
	while read ID; do
		echo -n $ID\ >>$1.rst
		zcat $a17k/imp/{1..26}.vcf.gz |
			$bin/vcf-excl $ID |
			gzip -c >$ID.ref.vcf.gz # also create a $ID.vcf file for comparision
		grep -v \# $ID.vcf |
			gawk '{print $NF}' >$ID.2
		cat $ID.vcf |
			$bin/msk-eth 1 5 >$ID.msk.vcf
		java -Xmx2G -jar $bin/beagle.jar \
			ref=$ID.ref.vcf.gz \
			gt=$ID.msk.vcf \
			window=200 \
			nthreads=1 \
			ne=$ne \
			out=$ID.imp
		zcat $ID.imp.vcf.gz |
			grep -v \# |
			gawk '{print $NF}' >$ID.1
		paste $ID.{1,2} |
			$bin/ivcf-cmp 1 5 >>$1.rst
		rm $ID.*
	done <$1
}

post-analysis() {
	cat rst.txt |
		$bin/qerr-mrg >err.bm
	# Determine number of loci on each chromosome
	for i in {1..26}; do
		zcat $a17k/imp/$chr.vcf.gz |
			grep -v \# | wc
	done | gawk '{print $1}' >chr.nlc

}

quanlity-control() {
	prepare-data
	get-ID-n-SNP
	for idset in x{00..19}; do
		touch $idset.rst
		qc-on-id $idset &
	done
	wait
}
