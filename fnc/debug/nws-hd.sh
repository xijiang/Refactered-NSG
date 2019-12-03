# In the previous test, I found that the 622 data are quite embarassing.
# These ID were chosen to improve imputation.  But when I use them, even as
# extra supplement to the existing reference, there are increased error rate.
# As these 622 ID include a few breeds, I will just use the Norwegian white
# sheep after year 1999 to serve as reference.
# Since the total number of these sheep is 622, I call this sub 622

prepare-working-dir(){
    date
    echo Check if 17k data and 606k data are ready
    
    if [ ! -d $l2mT ]; then
        source fnc/l2m-imputation.sh
        lmr
    fi
    if [ ! -d $HDGT ]; then
        source fnc/606k.sh
        e17k
    fi
}

prepare-data-622(){
    date
    echo Extract the genotypes of the 622 data from v4
    wdir=$HDGT/622v4/17k
    if [ -d $wdir ]; then rm -rf $wdir; fi
    mkdir -p $wdir
    cd $wdir
    tail -n+2 $ids/id.lst |
	gawk '{if(length($4)>2 && $9==10 && $7>1999) print $2}' >622.id
    for chr in {1..26}; do
	zcat $HDGT/v4/17k/$chr.vcf.gz |
	    $bin/vcf-by-id 622.id |
	    gzip -c >$chr.vcf.gz
    done
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

l2mr-6d-2-50(){
    echo This is to ramdomly sample 622 ID from MD data as ref
    echo Randomly sample 50 ID from MD data as msk
    echo mask msk and imputed them back with ref
    echo also impute with 622 HD sub SNP set on the msk
    echo Compare these two accuracies
    echo Note, reduced means shared loci between MD and HD were used.
    
    wdir=$l2mT/622-vs-random/622-only
    if [ -d $wdir ]; then rm -rf $wdir; fi
    mkdir -p $wdir
    cd $wdir
    touch rates
    cat $l2mT/ld.snp |
	$bin/impsnp $l2mT/reduced/v3/17k-at-hd.snp >imputed.snp

    for i in {1..10}; do
	sample-id 622 50
	touch {ran,622}.gt
	cmp-gt
	
	for chr in {1..26}; do
	    sample-ref $chr ref.id ref
	    sample-msk $chr
	    impute-n-collect ref.vcf.gz                  ran.gt
	    impute-n-collect $HDGT/622v4/17k/$chr.vcf.gz 622.gt
	done

	paste {cmp,ran}.gt |
            $bin/cor-err >>rates
	paste {cmp,622}.gt |
	    $bin/cor-err >>rates
	rm {cmp,ran,622}.gt
    done
}

l2mr-6k-step(){
    echo sample 50 from MD as msk
    echo sample 50..100..1500 extra from MD
    echo together with 622 data to impute msk back
    echo sample 622+50..1500 from MD as ref to impute msk
    echo compare these two accuracies
    
    wdir=$l2mT/622-vs-random/inc6d-vs-random
    if [ -d $wdir ]; then rm -rf $wdir; fi
    mkdir -p $wdir
    cd $wdir
    touch rates
    cat $l2mT/ld.snp |
	$bin/impsnp $l2mT/reduced/v3/17k-at-hd.snp >imputed.snp
    for sup in `seq 50 200 1500`; do
	let nref=sup+622
	echo $nref 50 >>rates
	sample-id $nref 50
	cmp-gt
	shuf shuf.id |
	    head -$sup >sup.id
	touch {ran,622}.gt
	for chr in {1..26}; do
	    sample-ref $chr ref.id ref
	    sample-msk $chr
	    impute-n-collect ref.vcf.gz ran.gt
	    
	    sample-ref $chr sup.id sup
	    $bin/vcf-paste \
		<(zcat $HDGT/622v4/17k/$chr.vcf.gz) \
		<(zcat sup.vcf.gz) |
		gzip -c >ref.vcf.gz
	    impute-n-collect ref.vcf.gz 622.gt
	done
	paste {cmp,ran}.gt |
	    $bin/cor-err >>rates
	paste {cmp,622}.gt |
	    $bin/cor-err >>rates
	rm {cmp,ran,622}.gt
    done
}

l2mr-extra-6d(){
    echo ===== sample 500-100-1000 as ref
    echo ===== sample 50 as msk
    echo ===== impute msk with ref
    echo ===== impute msk with ref+622
    echo ===== compare these two accuracies

    wdir=$l2mT/622-vs-random/extra-8d-vs-random
    if [ -d $wdir ]; then rm -rf $wdir; fi
    mkdir -p $wdir
    cd $wdir
    touch rates
    cat $l2mT/ld.snp |
	$bin/impsnp $l2mT/reduced/v3/17k-at-hd.snp >imputed.snp
    for ref in `seq 1000 100 1500`; do
	sample-id $ref 50
	cmp-gt
	touch {ran,622}.gt
	for chr in {1..26}; do
	    sample-ref $chr ref.id ref
	    sample-msk $chr
	    impute-n-collect ref.vcf.gz ran.gt
	    
	    $bin/vcf-paste \
		<(zcat $HDGT/622v4/17k/$chr.vcf.gz) \
		<(zcat ref.vcf.gz) |
		gzip -c >ex.vcf.gz
	    impute-n-collect ex.vcf.gz 622.gt
	done
	paste {cmp,ran}.gt |
	    $bin/cor-err >>rates
	paste {cmp,622}.gt |
	    $bin/cor-err >>rates
	rm {cmp,ran,622}.gt
    done
}

6d-v-ran-lmr(){
    prepare-working-dir
    prepare-data-622

    #l2mr-6d-2-50
    l2mr-6k-step
    l2mr-extra-6d
    
    # Plot figures
    cd $l2mT/622-vs-random
    #./622vs-related.jl
}
