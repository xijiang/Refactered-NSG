prepare-17ka-dir(){
    ##################################################
    date
    echo Prepare directory and files
    if [ -d $a17k ]; then
	ligth=red
	response=
	echo
	echo $a17k exists.  Are you sure you want to re-do it? [yes / other]
	read response
	if [ $response == yes ]; then
	    rm -rf $a17k
	    light=green
	fi
    fi

    if [ $light==green ]; then
	mkdir -p $a17k/{pre,log}
	cd $a17k/pre

	# link the available genotype files here
	gfiles=`ls $genotypes/a17k/`
	ln -s $genotypes/a17k/* .
	
	# make ID info and map ready
	tail -n+2 $ids/id.lst |
	    gawk '{if(length($6)>2 && $9==10 && $7>1999) print $6, $2}' >17k.id

	$bin/mrg2bgl 17k.id $maps/17k.map $gfiles
    fi
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

merge-17k(){
    light=green
    
    prepare-17ka-dir

    if [ $light==green ]; then
	create-one-vcf
    fi
}
