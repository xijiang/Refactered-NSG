CXXFLAGS = -O2 -Wall -std=c++17
THREAD = ${CXXFLAGS} -pthread

target=latest-beagle mrg2bgl vcf2g vr1g g2-3c impsnp mskloci extrgt cor-err \
	vcf-by-id vcf-paste vcf-by-loci missing-rt snpmatch vcfsort vcf-stat \
	vcf-excl msk-ith ivcf-cmp qerr-mrg to-v4 qc-2d qc-2d-sum ljvcf rnd-msk

all:    ${target}

mv:
	mkdir -p ../bin
	mv ${target} ../bin

.PHONY: clean

clean:
	rm -f ${target}
