# Check the imputation results from 8k to 17k with version 4 map.
# note, here the loci on 17k, but missing on HD were merged.
# in the end I have 14764 autosomal loci
# I randomly chose 40 ID twice, mask SNP diff between 8k and 17k and then impute them back

prepare-data(){
    gawk '{print $1}'  $maps/17k.v4 >tmp
    cat tmp $maps/8k-17k.shared |
	sort |
	uniq -c |
	gawk '{if($1==1) print $2}' >imputed.snp
    rm tmp
    
    for rpt in {1..2}; do
	cat $QCD/17k.id |
	    shuf > random
	head -40 random >msk
	tail -n+41 random >ref
	zcat $QCD/pre.vcf.gz |
	    $bin/vcf-by-id msk |
	    $bin/mskloci $maps/8k-17k.shared |
	    gzip -c >msk.vcf.gz
	zcat $QCD/ref.vcf.gz |
	    $bin/vcf-by-id ref |
	    gzip -c >ref.vcf.gz
	java -jar $bin/beagle.jar \
	     nthreads=20 \
	     ref=ref.vcf.gz \
	     gt=msk.vcf.gz \
	     ne=$ne \
	     out=imp
	zcat imp.vcf.gz |
	    $bin/extrgt imputed.snp >imp.gt
	zcat $QCD/ref.vcf.gz |
	    $bin/vcf-by-id msk |
	    $bin/extrgt imputed.snp >cmp.gt
	paste {cmp,imp}.gt |
	    $bin/cor-err >>rates
	rm -f {cmp,imp}.gt
    done
}
