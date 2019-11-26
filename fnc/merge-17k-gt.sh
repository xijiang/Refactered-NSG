prepare-17ka-dir(){
    ##################################################
    date
    echo Prepare directory and files
    if [ -d $a17k ]; then rm -rf $a17k; fi
    mkdir -p $a17k/pre
    cd $a17k/pre

    # link the available genotype files here
    gfiles=`ls $genotypes/a17k/`
    ln -s $genotypes/a17k/* .
    
    # make ID info and map ready
    tail -n+2 $ids/id.lst |
	    gawk '{if(length($6)>2 && $9==10 && $7>1999) print $6, $2}' >17k.id

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

    cd $a17k
    
    zcat pre/1.vcf.gz |
	grep \# >ori.vcf
    zcat pre/{1..26}.vcf.gz |
	grep -v \# >>ori.vcf
    pigz ori.vcf
}

calculate-17ka-G(){
    ##################################################
    date
    echo Calculate G matrix
    cd ../imp
    zcat {1..26}.vcf.gz |
	    $bin/vcf2g |
	    $bin/vr1g >../17k-a.G

    mv ../pre/gmat.id ../17k-a.G.id

    cd ..
    cat 17k-a.G |
	    $bin/g2-3c 17k-a.G.id >17k-a.3c
}

merge-17k(){
    prepare-17ka-dir

    create-one-vcf
}
