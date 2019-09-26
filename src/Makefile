CXXFLAGS = -O2 -Wall -std=c++17
THREAD = ${CXXFLAGS} -pthread

target=latest-beagle mrg2bgl vcf2g vr1g g2-3c impsnp mskloci subid extrgt cor-err

all:    ${target}

mv:
	mkdir -p ../bin
	mv ${target} ../bin

.PHONY: clean

clean:
	rm -f ${target}
