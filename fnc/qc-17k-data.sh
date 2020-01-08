# For 17k alpha genotypes

prepare-data() {
    if [ ! -d $a17k ]; then
	source $base/fnc/merge-17k-gt-in-design-format.sh
	merge-17k
    fi

    cd $a17k
    if [ ! -f ref.vcf.gz ]; then
	java -jar $bin/beagle.jar \
	     gt=ori.vcf.gz \
	     ne=$ne \
	     out=ref >log/ref.log
    fi

    if [ -d $qcd ]; then
	response=
	echo Are you sure that you want to re-run QC [yes / other]?
	read response
	if [ ! $response == "yes" ]; then
	    light=red
	else
	    rm -rf $qcd;
	fi
    fi
}

quality-control-17k(){
    light=green
    qcd=$a17k/qcd

    prepare-data
    if [ $light == green ]; then
	mkdir -p $qcd/{rst,log}	# dir tmp is made by make-qc-groups
	cd $qcd
	
	general-statisitcs
	make-qc-groups
	for rpt in `seq -w $nrepeats`; do
	    echo
	    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
	    echo Dealing with repeat $rpt
	    echo
	    cd $qcd/tmp/$rpt
	    stride-on-snp $rpt
	    for flog in *.log; do
		mv $flog ../../log/$rpt.$flog
	    done
	done
	cd $qcd
	qc-summarize
    fi
}
