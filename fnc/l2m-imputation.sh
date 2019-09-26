# check imputation rate from 8k to 17k
# Several thousand of ID were genotyped with 17k chips
# 8k is majorly a subset of 17k,
# it is handy to mask a few to check imputation.

prepare-a-working-directory(){
    if [ ! -d $a17k ]; then
    	source $base/fnc/17k-alpha.sh
        prepare-17ka-dir
        impute-17ka-missing-gt
    fi

    if [ -d $l2mT ]; then rm -rf $l2mT; fi
    mkdir -p $l2mT
    rst=$l2mT/rates.txt
    cd $l2mT
    
    # all ID available
    zcat $a17k/imp/1.vcf.gz |
        head |
        tail -1 |
        tr '\t' '\n' |
        tail -n+10 >md.id
    # autosomal SNP on the 17k chip
    zcat $a17k/imp/{1..26}.vcf.gz |
        grep -v \# |
        gawk '{print $3}' >md.snp
    # autosomal SNP on the 8k chip
    cat $maps/7327.map |
        gawk '{print $2}' >ld.snp
    # SNP to be imputed
    cat ld.snp |
        $bin/impsnp md.snp >imputed.snp
}

make-ref-files(){
    for chr in {1..26}; do
        zcat $a17k/imp/$chr.vcf.gz |
            $bin/vcf-by-id $1 |
            gzip -c >ref.$chr.vcf.gz
    done
}

make-imp-files(){
    for chr in {1..26}; do      # mask to impute
        zcat $a17k/pre/$chr.vcf.gz |
            $bin/vcf-by-id $1 |
            $bin/mskloci $l2mT/ld.snp |
            gzip -c >msk.$chr.vcf.gz
        
        # The 'correct' genotype to compare
        zcat $a17k/imp/$chr.vcf.gz |
            $bin/vcf-by-id $1 |
            gzip -c >cmp.$chr.vcf.gz
    done
}

impute-n-compare(){
    for chr in {1..26}; do
        java -jar $bin/beagle.jar \
             ref=ref.$chr.vcf.gz \
             gt=msk.$chr.vcf.gz \
             ne=$ne \
             out=imp.$chr
    done

    zcat cmp.{1..26}.vcf.gz |
        $bin/extrgt $l2mT/imputed.snp >cmp.gt
    zcat imp.{1..26}.vcf.gz |
        $bin/extrgt $l2mT/imputed.snp >imp.gt
    paste {cmp,imp}.gt |
        $bin/cor-err >>$rst
}

test-less2more(){
    prepare-a-working-directory
    
    # with a fixed set of reference, increase pop size to be imputed.
    # see if the imputation error increases
    wdir=$l2mT/fix2more-n-more
    mkdir -p $wdir
    cd $wdir
    rst=$wdir/rates
    touch $rst
    
    cat $l2mT/md.id |
        shuf >shuf.id
    
    head -n 500 shuf.id >ref.id
    make-ref-files ref.id
    
    tail -n+501 shuf.id >pool.id
    for nto in `seq 50 100 200`; do
        cat pool.id |
            shuf |
            head -n $nto >imp.id
        make-imp-files imp.id
        echo 500 $nto >>$rst
        impute-n-compare
    done
}
