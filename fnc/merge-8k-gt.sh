merge-8k-genotypes(){
    if [ -d $g8k ]; then
	response=
	echo $g8k exists, are you sure you want to continue? [ yes / other ]
	read response
	if [ ! $response == yes ]; then
	    return 1
	fi
    fi
    
    rm -rf $g8k
    mkdir -p $g8k/{pre,log}
    cd $g8k/pre

    # link the available genotype files here
    gfiles=`ls $genotypes/7327/`
    ln -s $genotypes/7327/* .
    
    # make ID info and map ready
    tail -n+2 $ids/id.lst |
	    gawk '{if(length($3)>2 && $9==10 && $7>1999 && length($4)<4) print $3, $2}' >idinfo
    
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
