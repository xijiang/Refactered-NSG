prepare-data() {
    if [ ! -d $g6dk ]; then
	source $base/fnc/merge-606k-gt.sh
	merge-6dk-genotypes
    fi
    if [ -d $qcd ]; then rm -rf $qcd; fi
    mkdir -p $qcd/rst
    cd $g6dk
    if [ ! -f ref.vcf.gz ]; then
	java -jar $bin/beagle.jar \
	     gt=ori.vcf.gz \
	     ne=$ne \
	     out=ref
    fi
}

quality-control-6dk(){
    qcd=$g6dk/qcd
    prepare-data
    cd $qcd
    general-statisitcs
    cd $qcd
    stride-on-snp $grpsz6dk
    cd $qcd
    qc-summarize
}
