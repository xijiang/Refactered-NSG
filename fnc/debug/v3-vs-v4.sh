# impute with `which ID to be genotyped`
# these ID were 606k genotyped
# extract their 17k loci according 17k chips
# use them as nuclear reference, randomly add other to 1k
# randomly select 50 ID from 17k genotyped
# mask and impute, and evaluate the imputation results
# may consider breeds

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
}

reduced-17k-dat-v3(){
    echo 17k chip has 14974 loci
    echo it shares 13281 loci with 606k chip
    echo I reduce 17k loci to 13281

    wdir=$l2mT/reduced/v3
    mkdir -p $wdir/{ref,pre}
    cd $wdir
    zcat $HDGT/v3/17k/{1..26}.vcf.gz |
        grep -v \# |
        gawk '{print $3}' >17k-at-hd.snp
    for chr in {1..26}; do
        zcat $a17k/imp/$chr.vcf.gz |
            $bin/vcf-by-loci 17k-at-hd.snp |
            gzip -c >ref/$chr.vcf.gz
	zcat $a17k/pre/$chr.vcf.gz |
	    $bin/vcf-by-loci 17k-at-hd.snp |
	    gzip -c >pre/$chr.vcf.gz
    done
}

order-gt-2-v4(){
    zcat ../v3/$1/1.vcf.gz |
	grep \# >header
    zcat ../v3/$1/{1..26}.vcf.gz |
	grep -v \# |
	$bin/vcfsort v4.map
    for chr in {1..26}; do
	cat header $chr.vcf |
	    gzip -c >$1/$chr.vcf.gz
    done
    rm header *.vcf
}

v3-2-v4(){
    echo I merge the genotypes of all loci,
    echo and then divided them into chromosomes according to snpChimp v4
    wdir=$l2mT/reduced/v4
    if [ -d $wdir ]; then rm -rf $wdir; fi
    mkdir -p $wdir/{pre,ref}
    cd $wdir
    echo
    echo create map.v4 on 13281 loci
    tail -n+2 $maps/sheep-snpchimp.v4 |
	gawk '{if($11>0 && $11<27) print $13, $11, $12}' |
	sort -nk2 -nk3 |
	$bin/snpmatch ../v3/17k-at-hd.snp >v4.map
    order-gt-2-v4 pre
    order-gt-2-v4 ref
}

sample-id(){
    cat $l2mT/md.id |
        shuf >shuf.id
    head -n $1 shuf.id >ref.id
    tail -n $2 shuf.id >imp.id
}

mask-n-impute(){
    touch cmp.gt imp.gt
    
    for chr in {1..26}; do
	zcat $l2mT/reduced/$1/ref/$chr.vcf.gz |
	    $bin/vcf-by-id ../imp.id |
	    $bin/extrgt ../imputed.snp >>cmp.gt
    done

    for chr in {1..26}; do
        zcat $l2mT/reduced/$1/ref/$chr.vcf.gz |
            $bin/vcf-by-id ../ref.id |
            gzip -c >ref.vcf.gz # reference, no chr name
        zcat $l2mT/reduced/$1/pre/$chr.vcf.gz |
	    $bin/vcf-by-id ../imp.id |
            $bin/mskloci $l2mT/ld.snp |
            gzip -c >msk.vcf.gz
        java -jar $bin/beagle.jar \
	     nthreads=20 \
             ref=ref.vcf.gz \
             gt=msk.vcf.gz \
             ne=$ne \
             out=imp
	zcat imp.vcf.gz |
	    $bin/extrgt ../imputed.snp >>imp.gt
    done

    paste {cmp,imp}.gt |
        $bin/cor-err >>rates
    rm -f {cmp,imp}.gt
}

l2mr-within-reduced(){
    echo Test map v3 vs v4, which is better
    echo Here I randomly sample 1000 ID from reduced 17k data as reference
    echo sample 50 ID from the rest of the reduced 17k data to be masked
    echo then impute the same data set according to map v3 and v4
    echo to check imputation rate
    echo I repeat above 10 times
    
    wdir=$l2mT/reduced-ref1k-msk50
    if [ -d $wdir ]; then rm -rf $wdir; fi
    mkdir -p $wdir/{v3,v4}
    cat $l2mT/ld.snp |
	$bin/impsnp $l2mT/reduced/v3/17k-at-hd.snp >$wdir/imputed.snp
    for i in {1..10}; do
	echo Repeat $i, sampling ID
	cd $wdir
	sample-id 1000 50
	cd $wdir/v3
	touch rates
	mask-n-impute v3
	cd $wdir/v4
	touch rates
	mask-n-impute v4
    done
}

new-lmr(){
    prepare-required-data
    reduced-17k-dat-v3
    v3-2-v4
    l2mr-within-reduced
}
