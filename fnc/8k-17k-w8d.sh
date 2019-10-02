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

reduced-17k-dat(){
    echo 17k chip has 14974 loci
    echo it shares 13281 loci with 606k chip
    echo I reduce 17k loci to 13281
    wdir=$l2mT/reduced
    mkdir -p $wdir
    cd $wdir
    zcat $HDGT/17k/ref/{1..26}.vcf.gz |
        grep -v \# |
        gawk '{print $3}' >17k-at-hd.snp
    for chr in {1..26}; do
        zcat $a17k/imp/$chr.vcf.gz |
            $bin/vcf-by-loci 17k-at-hd.snp |
            gzip -c >$chr.vcf.gz
    done
}

l2mr-within-reduced(){
    echo Here I randomly sample 1000 ID from reduced 17k data as reference
    echo sample 50 ID from the rest of the reduced 17k data to be masked
    echo then impute them back and check imputation rate
    echo I repeat above 20 times
    
    wdir=$l2mT/reduced-ref1k-msk50
    if [ -d $wdir ]; then rm -rf $wdir; fi
    mkdir -p $wdir
    cd $wdir
    touch rates
    cat ../ld.snp |
        $bin/impsnp ../reduced/17k-at-hd.snp >imputed.snp

    for rpt in {1..20}; do
        cat ../md.id |
            shuf >shuf.id
        head -n 1000 shuf.id >ref.id
        tail -n 50   shuf.id >imp.id

        for chr in {1..26}; do
            zcat ../reduced/$chr.vcf.gz |
                $bin/vcf-by-id ref.id |
                gzip -c >ref.vcf.gz # reference, no chr name
            zcat ../reduced/$chr.vcf.gz |
                $bin/vcf-by-id imp.id |
                gzip -c >cmp.$chr.vcf.gz
            zcat cmp.$chr.vcf.gz |
                $bin/mskloci ../ld.snp |
                gzip -c >msk.vcf.gz
            java -jar $bin/beagle.jar \
                 ref=ref.vcf.gz \
                 gt=msk.vcf.gz \
                 ne=$ne \
                 out=imp.$chr
        done
        zcat cmp.{1..26}.vcf.gz |
            $bin/extrgt imputed.snp >cmp.gt
        zcat imp.{1..26}.vcf.gz |
            $bin/extrgt imputed.snp >imp.gt
        paste {cmp,imp}.gt |
            $bin/cor-err >>rates
    done
}

l2mr-with-8d-data(){
    echo Here I always use the 828 data
    echo randomly sample 172 ID from MD data to make it 1000
    echo randomly sample 50 ID from the rest to be masked
    echo then impute, check error
    echo I repeat above 20 times
    wdir=$l2mT/ref8d1k-imp50
    if [ -d $wdir ]; then rm -rf $wdir; fi
    mkdir -p $wdir
    cd $wdir
    touch rates
    cat ../ld.snp |
        $bin/impsnp ../reduced/17k-at-hd.snp >imputed.snp

    for rpt in {1..20}; do
        cat ../md.id |
            shuf >shuf.id
        head -n 172 shuf.id >ref.id
        tail -n 50  shuf.id >imp.id

        for chr in {1..26}; do
            zcat ../reduced/$chr.vcf.gz |
                $bin/vcf-by-id ref.id |
                gzip -c >tmp.vcf.gz
            $bin/vcf-paste <(zcat $HDGT/17k/ref/$chr.vcf.gz) <(zcat tmp.vcf.gz) |
                gzip -c >ref.vcf.gz
            zcat ../reduced/$chr.vcf.gz |
                $bin/vcf-by-id imp.id |
                gzip -c >cmp.$chr.vcf.gz
            zcat cmp.$chr.vcf.gz |
                $bin/mskloci ../ld.snp |
                gzip -c >msk.vcf.gz
            java -jar $bin/beagle.jar \
                 ref=ref.vcf.gz \
                 gt=msk.vcf.gz \
                 ne=$ne \
                 out=imp.$chr
        done
        zcat cmp.{1..26}.vcf.gz |
            $bin/extrgt imputed.snp >cmp.gt
        zcat imp.{1..26}.vcf.gz |
            $bin/extrgt imputed.snp >imp.gt
        paste {cmp,imp}.gt |
            $bin/cor-err >>rates
    done
}

new-lmr(){
    #prepare-required-data
    #reduced-17k-dat
    #l2mr-within-reduced

    # I found that 17k map is different from 606k map
    # so I stop here and may pick this up again.
    l2mr-with-8d-data
}
