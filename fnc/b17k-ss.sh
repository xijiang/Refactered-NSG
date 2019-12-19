prepare-17kb-dir(){
    ##################################################
    date
    echo Prepare directory and files
    if [ -d $b17k ]; then rm -rf $b17k; fi
    mkdir -p $b17k/pre
    cd $b17k/pre

    # link the available genotype files here
    gfiles=`ls $genotypes/b17k/`
    ln -s $genotypes/b17k/* .
    
    # make ID info and map ready
    tail -n+2 $ids/id.lst |
	gawk '{if(length($5)>2 && $9==10) print $5, $2}' >17k.id

    # prepare a map
    $bin/mrg2bgl 17k.id $maps/17k.map $gfiles
}

create-one-vcf(){
    ##################################################
    date
    echo Convert to vcf format and merge to one file
    for chr in {26..1}; do
    	java -jar $bin/beagle2vcf.jar $chr $chr.mrk $chr.bgl - |
            gzip -c >$chr.vcf.gz
    done

    cd $b17k
    
    zcat pre/1.vcf.gz |
	grep \# >ori.vcf
    zcat pre/{1..26}.vcf.gz |
	grep -v \# >>ori.vcf
    pigz ori.vcf
}

merge-17kb(){
    prepare-17kb-dir

    create-one-vcf
}
