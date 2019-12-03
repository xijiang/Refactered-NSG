merge-8k-genotypes(){
    if [ -d $g8k ]; then rm -rf $g8k; fi
    mkdir -p $g8k/pre
    cd $g8k/pre

    # link the available genotype files here
    gfiles=`ls $genotypes/7327/`
    ln -s $genotypes/7327/* .
    
    # make ID info and map ready
    tail -n+2 $ids/id.lst |
	    gawk '{if(length($3)>2 && $9==10 && $7>1999) print $3, $2}' >idinfo
    
    $bin/mrg2bgl idinfo $maps/8k.map $gfiles

    for chr in {26..1}; do
	    java -jar $bin/beagle2vcf.jar $chr $chr.mrk $chr.bgl - |
            gzip -c >$chr.vcf.gz
    done

    zcat 26.vcf.gz | grep \# >../ori.vcf
    for chr in {1..26}; do
	zcat $chr.vcf.gz | grep -v \# >>../ori.vcf
    done
    cd ..
    pigz ori.vcf
}
