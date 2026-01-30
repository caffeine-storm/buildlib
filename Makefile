SHELL:=/bin/bash

all: release

version:=${file <VERSION}
releasedir:=buildlib-v${version}
releasetarball:=${releasedir}.tar.gz

release: ${releasetarball}
 
${releasetarball}: dist
	tar -acf $@ '--transform=s,^$^,${releasedir},' $^

clean:
	rm -rf ${releasetarball} ${releasedir}

test:
	./test/all.sh

.PHONY: all release clean test
