# Get the latest Beagle
# -- Notice the name of nightly Beagle is like beagle.ddMMMyy.xyz.jar
# -- at the following URL
# -- So, I ordered them on yymmdd, and return the absolute address
# -- of the latest Beagle.
the-latest-beagle(){
    # Notice the name of nightly Beagle is like beagle.ddMMMyy.xyz.jar
    # at the following URL
    # So, I ordered them on yymmdd, and return the absolute address
    # of the latest Beagle.

    #echo -n https://faculty.washington.edu/browning/beagle/
    curl -sl https://faculty.washington.edu/browning/beagle/ |
        grep beagle.*jar |
        gawk -F\" '{print $6}' |
        gawk -F\. '{if(NF==4) print $0}' |
        $bin/latest-beagle
}


get-beagle-related(){
    beagle=`the-latest-beagle`
    echo Current version $beagle
    mkdir -p $bin
    cd $bin
    if [ ! -f $beagle ]; then
	curl https://faculty.washington.edu/browning/beagle/$beagle -o $beagle
    fi
    
    if [ -f beagle.jar ]; then rm -f beagle.jar; fi
    ln -s $beagle beagle.jar

    if [ ! -f beagle2vcf.jar ]; then
    	wget https://faculty.washington.edu/browning/beagle_utilities/beagle2vcf.jar
    fi
    
    cd $base
}
