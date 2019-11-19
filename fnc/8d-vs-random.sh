#  In the previous test, I demonstrated that map version 4 gives better
#  imputation versus version 3.
#  In this test, I will test if using genotypes of the 828, which I picked
#  with my algorithm for better imputation, gives better imputation.
#  I will do 10 repeats. In each repeat, I
#      1) randomly select 50 ID to mask, later to imputed them back
#      2) randomly select 828 ID from MD data, as reference
#      3) use the 828 sub data as reference

prepare-required-data(){
    echo Check if 17k data and 606k data are ready
    
    if [ ! -d $l2mT ]; then
        source fnc/l2m-imputation.sh
        lmr
    fi
    if [ ! -d $HDGT ]; then
        source fnc/606k.sh
        e17k
    fi
    cp $julia/828vs-related.jl $l2mT/828-vs-random
}

sample-id(){
    cat $l2mT/md.id |
        shuf >shuf.id
    head -n $1 shuf.id >ref.id
    tail -n $2 shuf.id >imp.id
}

cmp-gt(){
    touch cmp.gt
    for chr in {1..26}; do
	zcat $l2mT/reduced/v4/ref/$chr.vcf.gz |
	    $bin/vcf-by-id imp.id |
	    $bin/extrgt imputed.snp >>cmp.gt
    done
}

sample-ref(){
    zcat $l2mT/reduced/v4/ref/$1.vcf.gz |
        $bin/vcf-by-id $2 |
        gzip -c >$3.vcf.gz # reference, no chr name
}

sample-msk(){
    zcat $l2mT/reduced/v4/pre/$1.vcf.gz |
	$bin/vcf-by-id imp.id |
        $bin/mskloci $l2mT/ld.snp |
        gzip -c >msk.vcf.gz
}

impute-n-collect(){
    java -jar $bin/beagle.jar \
	 nthreads=20 \
         ref=$1 \
         gt=msk.vcf.gz \
         ne=$ne \
         out=imp
    zcat imp.vcf.gz |
	$bin/extrgt imputed.snp >>$2
}

l2mr-8d-2-50-reduced(){
    echo This is to ramdomly sample 828 ID from MD data as ref
    echo Randomly sample 50 ID from MD data as msk
    echo mask msk and imputed them back with ref
    echo also impute with 828 HD sub SNP set on the msk
    echo Compare these two accuracies
    echo Note, reduced means shared loci between MD and HD were used.
    
    wdir=$l2mT/828-vs-random/828-only
    if [ -d $wdir ]; then rm -rf $wdir; fi
    mkdir -p $wdir
    cd $wdir
    touch rates
    cat $l2mT/ld.snp |
	$bin/impsnp $l2mT/reduced/v3/17k-at-hd.snp >imputed.snp

    for i in {1..10}; do
	sample-id 828 50
	touch {ran,828}.gt
	cmp-gt
	
	for chr in {1..26}; do
	    sample-ref $chr ref.id ref
	    sample-msk $chr
	    impute-n-collect ref.vcf.gz               ran.gt
	    impute-n-collect $HDGT/v4/17k/$chr.vcf.gz 828.gt
	done

	paste {cmp,ran}.gt |
            $bin/cor-err >>rates
	paste {cmp,828}.gt |
	    $bin/cor-err >>rates
	rm {cmp,ran,828}.gt
    done
}

l2mr-8k-step-reduced(){
    echo sample 50 from MD as msk
    echo sample 50..100..1500 extra from MD
    echo together with 828 data to impute msk back
    echo sample 828+50..1500 from MD as ref to impute msk
    echo compare these two accuracies
    
    wdir=$l2mT/828-vs-random/inc8d-vs-random
    if [ -d $wdir ]; then rm -rf $wdir; fi
    mkdir -p $wdir
    cd $wdir
    touch rates
    cat $l2mT/ld.snp |
	$bin/impsnp $l2mT/reduced/v3/17k-at-hd.snp >imputed.snp
    for sup in `seq 50 200 1500`; do
	let nref=sup+828
	echo $nref 50 >>rates
	sample-id $nref 50
	cmp-gt
	shuf shuf.id |
	    head -$sup >sup.id
	touch {ran,828}.gt
	for chr in {1..26}; do
	    sample-ref $chr ref.id ref
	    sample-msk $chr
	    impute-n-collect ref.vcf.gz ran.gt
	    
	    sample-ref $chr sup.id sup
	    $bin/vcf-paste \
		<(zcat $HDGT/v4/17k/$chr.vcf.gz) \
		<(zcat sup.vcf.gz) |
		gzip -c >ref.vcf.gz
	    impute-n-collect ref.vcf.gz 828.gt
	done
	paste {cmp,ran}.gt |
	    $bin/cor-err >>rates
	paste {cmp,828}.gt |
	    $bin/cor-err >>rates
	rm {cmp,ran,828}.gt
    done
}

l2mr-extra-8d-reduced(){
    echo ===== sample 500-100-1000 as ref
    echo ===== sample 50 as msk
    echo ===== impute msk with ref
    echo ===== impute msk with ref+828
    echo ===== compare these two accuracies

    wdir=$l2mT/828-vs-random/extra-8d-vs-random
    if [ -d $wdir ]; then rm -rf $wdir; fi
    mkdir -p $wdir
    cd $wdir
    touch rates
    cat $l2mT/ld.snp |
	$bin/impsnp $l2mT/reduced/v3/17k-at-hd.snp >imputed.snp
    for ref in `seq 1000 100 1500`; do
	sample-id $ref 50
	cmp-gt
	touch {ran,828}.gt
	for chr in {1..26}; do
	    sample-ref $chr ref.id ref
	    sample-msk $chr
	    impute-n-collect ref.vcf.gz ran.gt
	    
	    $bin/vcf-paste \
		<(zcat $HDGT/v4/17k/$chr.vcf.gz) \
		<(zcat ref.vcf.gz) |
		gzip -c >ex.vcf.gz
	    impute-n-collect ex.vcf.gz 828.gt
	done
	paste {cmp,ran}.gt |
	    $bin/cor-err >>rates
	paste {cmp,828}.gt |
	    $bin/cor-err >>rates
	rm {cmp,ran,828}.gt
    done
}

8d-v-ran-lmr(){
    prepare-required-data
    l2mr-8d-2-50-reduced
    l2mr-8k-step-reduced
    l2mr-extra-8d-reduced
    
    # Plot figures
    cd $l2mT/828-vs-random
    ./828vs-related.jl
}
