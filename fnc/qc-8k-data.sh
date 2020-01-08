# for the 8k LD genotypes

prepare-data-8k() {
    if [ ! -d $g8k ]; then
	source $base/fnc/merge-8k-gt.sh
	merge-8k-genotypes
    fi
    
    cd $g8k
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
	    rm -rf $qcd
	fi
    fi
}

quality-control-8k(){
    light=green
    qcd=$g8k/qcd

    prepare-data-8k
    if [ $light == green ]; then
	mkdir -p $qcd/{rst,log}
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
