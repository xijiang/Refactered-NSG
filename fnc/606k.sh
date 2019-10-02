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
        gawk '{if(length($4)>2) print $4, $2}' >606k.id

    tail -n+2 $maps/sheep-snpchimp-v.4 |
        gawk '{print $13, $11, $12}' >606k.map
    
    $bin/mrg2bgl 606k.id 606k.map $g606k

    for chr in {1..26}; do
        java -jar $bin/beagle2vcf.jar $chr $chr.mrk $chr.bgl - |
            gzip -c >$chr.vcf.gz
        java -jar $bin/beagle.jar \
             gt=$chr.vcf.gz \
             ne=$ne \
             out=../imp/$chr
    done
}

sub-17k(){
    if [ ! -d $a17k ]; then
        source $base/fnc/17k-alpha.sh
        prepare-17ka-dir
        impute-17ka-missing-gt
    fi
    mkdir -p $HDGT/17k/{ref,sub}
    cd $HDGT/17k/
    zcat $a17k/imp/{1..26}.vcf.gz |
        grep -v \# |
        gawk '{print $3}' >17k.snp
    for chr in {1..26}; do
        zcat ../imp/$chr.vcf.gz |
            $bin/vcf-by-loci 17k.snp |
            gzip -c >ref/$chr.vcf.gz
        zcat ../pre/$chr.vcf.gz |
            $bin/vcf-by-loci 17k.snp |
            gzip -c >sub/$chr.vcf.gz
    done
}

e17k(){
    prepare-606k-directory
    
    impute-few-missing-606

    sub-17k
}
