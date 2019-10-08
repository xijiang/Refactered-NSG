# prepare 828 ID to vcf files
# extract genotypes on 17k loci
# fill missing loci
# use these as reference to impute LD to MD

prepare-606k-directory(){
    date
    verd=$HDGT/$1		# verd -> version dir
    
    if [ -d $verd ]; then rm -rf $verd; fi
    mkdir -p $verd/{pre,imp,17k}
    cd $verd

    g606k=`ls $genotypes/600k`
    ln -s $genotypes/600k/* $verd/pre
}

impute-few-missing-606(){
    wdir=$verd/pre
    cd $wdir

    tail -n+2 $ids/id.lst |
        gawk '{if(length($4)>2) print $4, $2}' >606k.id

    tail -n+2 $maps/sheep-snpchimp.$1 |
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
    mkdir -p $verd/17k/{ref,sub}
    cd $verd/17k/
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
    for ver in v3 v4; do
	echo dealing data according $ver.map
	
	prepare-606k-directory $ver
	
	impute-few-missing-606 $ver

	sub-17k
    done
}
