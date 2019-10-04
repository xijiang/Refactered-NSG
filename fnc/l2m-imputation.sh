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

    mkdir -p $l2mT
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

prepare-a-sub-dir(){
    wdir=$l2mT/$1
    if [ -d $wdir ]; then rm -rf $wdir; fi
    mkdir -p $wdir
    cd $wdir
    rst=$wdir/rates
    touch $rst
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

merge-n-impute(){
    for chr in {1..26}; do
        $bin/vcf-paste <(zcat ref.$chr.vcf.gz) <(zcat msk.$chr.vcf.gz) |
            gzip -c >one.$chr.vcf.gz
        java -jar $bin/beagle.jar \
             gt=one.$chr.vcf.gz \
             ne=$ne \
             out=x.$chr
        zcat x.$chr.vcf.gz |
            $bin/vcf-by-id imp.id |
            gzip -c >y.$chr.vcf.gz
    done

    zcat y.{1..26}.vcf.gz |
        $bin/extrgt $l2mT/imputed.snp >zzz.gt
    paste {cmp,zzz}.gt |
        $bin/cor-err >>$rst
}

fixed2-less2more(){
    # with a fixed set of reference, increase pop size to be imputed.
    # see if the imputation error increases
    prepare-a-sub-dir fix2more-n-more
    
    cat $l2mT/md.id |
        shuf >shuf.id
    
    head -n 1000 shuf.id >ref.id
    make-ref-files ref.id
    
    tail -n+1001 shuf.id >pool.id
    for nto in `seq 50 100 2000`; do
        cat pool.id |
            shuf |
            head -n $nto >imp.id
        make-imp-files imp.id
        echo 500 $nto >>$rst
        impute-n-compare
    done
    grep 'rate\|ent' rates |
        gawk '{print $NF}' >num.txt
    $julia/fix-2-less2more.jl
}

random-more2less(){
    prepare-a-sub-dir fix2fix
    
    for rpt in {1..50}; do
	    cat $l2mT/md.id |
	        shuf >shuf.id
	    head -n 50 shuf.id >imp.id
	    tail -n+51 shuf.id >ref.id
	    make-imp-files imp.id
	    make-ref-files ref.id
	    echo repeat $rpt >>$rst
	    impute-n-compare
    done
    grep 'rate\|ent' rates |
        gawk '{print $NF}' >num.txt
    $julia/fix-2-fix.jl
}

cmp-1vs2-beagle-file(){
    prepare-a-sub-dir 1vs2-files

    for rpt in {1..20}; do
        cat $l2mT/md.id |
            shuf >shuf.id
        head -n 100 shuf.id >imp.id
        tail -n+101 shuf.id >ref.id
        make-imp-files imp.id
        make-ref-files ref.id
        echo repeat $rpt >>$rst
        impute-n-compare
        merge-n-impute
    done
    grep 'rate\|ent' rates |
        gawk '{print $NF}' >num.txt
    $julia/one-vs-two.jl        # creates a figure
}

lmr(){
    prepare-a-working-directory
    
    fixed2-less2more
    
    random-more2less

    cmp-1vs2-beagle-file
}
