# prepare 828 ID to vcf files
# extract genotypes on 17k loci
# fill missing loci
# use these as reference to impute LD to MD

prepare-606k-directory(){
    date

    if [ -d $HDGT ]; then rm -rf $HDGT; fi
    mkdir -p $HDGT/{pre,imp,17k}
    cd $HDGT

    g606k=`ls $genotypes/600k`
    ln -s $genotypes/600k/* $HDGT/pre
}

impute-few-missing-606(){
    wdir=$HDGT/pre
    cd $wdir

    tail -n+2 $ids/id.lst |
        gawk '{if(length($4)>2} print $4, $2}' >606k.id

    tail -n+2 $maps/sheep-snpchimp-v.4 |
        gawk '{print $13, $11, $12}' >606k.map
    
    $bin/mrg2bgl 606k.id 606k.map $gfiles

    for chr in {1..26}; do
        java -jar $bin/beagle2vcf.jar $chr $chr.mrk $chr.bgl - |
            gzip -c >$chr.vcf.gz
        java -jar $bin/beagle.jar \
             gt=$chr.vcf.gz \
             ne=$ne \
             out=../imp/chr.vcf.gz
    done
}
    
# extract-17k-loci(){
#     if [ ! -d $a17k ]; then
#     	source $base/fnc/17k-alpha.sh
#         prepare-17ka-dir
#         impute-17ka-missing-gt
#     fi
# }
# 
# prepare-a-sub-dir(){
#     wdir=$l2mT/$1
#     if [ -d $wdir ]; then rm -rf $wdir; fi
#     mkdir -p $wdir
#     cd $wdir
#     rst=$wdir/rates
#     touch $rst
# }
# 
# make-ref-files(){
#     for chr in {1..26}; do
#         zcat $a17k/imp/$chr.vcf.gz |
#             $bin/vcf-by-id $1 |
#             gzip -c >ref.$chr.vcf.gz
#     done
# }
# 
# make-imp-files(){
#     for chr in {1..26}; do      # mask to impute
#         zcat $a17k/pre/$chr.vcf.gz |
#             $bin/vcf-by-id $1 |
#             $bin/mskloci $l2mT/ld.snp |
#             gzip -c >msk.$chr.vcf.gz
#         
#         # The 'correct' genotype to compare
#         zcat $a17k/imp/$chr.vcf.gz |
#             $bin/vcf-by-id $1 |
#             gzip -c >cmp.$chr.vcf.gz
#     done
# }
# 
# impute-n-compare(){
#     for chr in {1..26}; do
#         java -jar $bin/beagle.jar \
#              ref=ref.$chr.vcf.gz \
#              gt=msk.$chr.vcf.gz \
#              ne=$ne \
#              out=imp.$chr
#     done
# 
#     zcat cmp.{1..26}.vcf.gz |
#         $bin/extrgt $l2mT/imputed.snp >cmp.gt
#     zcat imp.{1..26}.vcf.gz |
#         $bin/extrgt $l2mT/imputed.snp >imp.gt
#     paste {cmp,imp}.gt |
#         $bin/cor-err >>$rst
# }
# 
# merge-n-impute(){
#     for chr in {1..26}; do
#         $bin/vcf-paste <(zcat ref.$chr.vcf.gz) <(zcat msk.$chr.vcf.gz) |
#             gzip -c >one.$chr.vcf.gz
#         java -jar $bin/beagle.jar \
#              gt=one.$chr.vcf.gz \
#              ne=$ne \
#              out=x.$chr
#         zcat x.$chr.vcf.gz |
#             $bin/vcf-by-id imp.id |
#             gzip -c >y.$chr.vcf.gz
#     done
# 
#     zcat y.{1..26}.vcf.gz |
#         $bin/extrgt $l2mT/imputed.snp >zzz.gt
#     paste {cmp,zzz}.gt |
#         $bin/cor-err >>$rst
# }
# 
# fixed2-less2more(){
#     # with a fixed set of reference, increase pop size to be imputed.
#     # see if the imputation error increases
#     prepare-a-sub-dir fix2more-n-more
#     
#     cat $l2mT/md.id |
#         shuf >shuf.id
#     
#     head -n 1000 shuf.id >ref.id
#     make-ref-files ref.id
#     
#     tail -n+1001 shuf.id >pool.id
#     for nto in `seq 50 100 2000`; do
#         cat pool.id |
#             shuf |
#             head -n $nto >imp.id
#         make-imp-files imp.id
#         echo 500 $nto >>$rst
#         impute-n-compare
#     done
# }
# 
# random-more2less(){
#     prepare-a-sub-dir fix2fix
#     
#     for rpt in {1..50}; do
# 	    cat $l2mT/md.id |
# 	        shuf >shuf.id
# 	    head -n 50 shuf.id >imp.id
# 	    tail -n+51 shuf.id >ref.id
# 	    make-imp-files imp.id
# 	    make-ref-files ref.id
# 	    echo repeat $rpt >>$rst
# 	    impute-n-compare
#     done
# }
# 
# cmp-1vs2-beagle-file(){
#     prepare-a-sub-dir 1vs2-files
# 
#     for rpt in {1..20}; do
#         cat $l2mT/md.id |
#             shuf >shuf.id
#         head -n 100 shuf.id >imp.id
#         tail -n+101 shuf.id >ref.id
#         make-imp-files imp.id
#         make-ref-files ref.id
#         echo repeat $rpt >>$rst
#         impute-n-compare
#         merge-n-impute
#     done
# }

e17k(){
    prepare-606k-directory
    
    impute-few-missing-606
}
