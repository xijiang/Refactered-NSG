merge-6dk-genotypes(){
    if [ -d $g6dk ]; then rm -rf $g6dk; fi
    mkdir -p $g6dk/{pre,log}
    cd $g6dk/pre

    # link the available genotype files here
    gfiles=`ls $genotypes/600k/`
    ln -s $genotypes/600k/* .
    
    # make ID info and map ready
    cat id.lst |
	gawk '{if($7>1999 && length($4)>2 && $9==10) print $4, $2}' >606k.id
    cat id.lst |
	gawk '{if($7<2000 && length($4)>2 && $8==1) print $4, $2}' >>606k.id
    
    $bin/mrg2bgl 606k.id $maps/606k.map $gfiles

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
