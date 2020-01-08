# for 606k genotypes

prepare-data() {
    if [ ! -d $g6dk ]; then
	source $base/fnc/merge-606k-gt.sh
	merge-6dk-genotypes
    fi
    
    cd $g6dk
    if [ ! -f ref.vcf.gz ]; then
	java -jar $bin/beagle.jar \
	     gt=ori.vcf.gz \
	     ne=$ne \
	     out=ref
    fi

    if [ -d $qcd ]; then
    	response=
	echo Are you sure that you want to re-run QC [yes / other]?
	read response
	if [ ! $response == "yes" ]; then
	    light=red
	else
	    rm -rf $qcd
	fi
    fi
}

quality-control-6dk(){
    light=green
    qcd=$g6dk/qcd

    prepare-data
    if [ $light == green ]; then
	mkdir -p $qcd/{log,rst}
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
