#!/usr/bin/env bash
. $2/fnc/parameters.sh $2

rpt=$1
qwrk=$QCD/$rpt.tmp

if [ -d $qwrk ]; then rm -rf $qwrk; fi

mkdir -p $qwrk
cd $qwrk

cat $QCD/17k.id |
    shuf |
    split -l $grpsize

msk=0

for grp in x*; do
    echo
    echo Dealing with file $grp
    zcat $a17k/ori.vcf.gz |
	$bin/vcf-by-id $grp |
	$bin/msk-ith $msk $qcblksize |
	gzip -c >msk.vcf.gz
    cat $grp $QCD/17k.id |
	sort |
	uniq -c |
	gawk '{if($1==1) print $2}' >ref
    zcat $a17k/ref.vcf.gz |
	$bin/vcf-by-id ref |
	gzip -c >ref.vcf.gz

    java -ea -Xmx3G -jar $bin/beagle.jar \
	 nthreads=4 \
	 ref=ref.vcf.gz \
	 gt=msk.vcf.gz \
	 ne=$ne \
	 out=imp

    zcat $a17k/ref.vcf.gz |
	$bin/vcf-by-id $grp |
	$bin/extrgt imputed.snp >cmp.gt
    zcat imp.vcf.gz |
	$bin/extrgt imputed.snp >imp.gt
    tar jcvf $QCD/rst/$1.$grp.tar.bz2 cmp.gt imp.gt $grp

    let msk=msk+1
    let msk=msk%$qcblksize
done
