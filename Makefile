SHELL:=/bin/bash

version:=${file <dist/VERSION}
releasedir:=buildlib-v${version}
releasetarball:=${releasedir}.tar.gz

all: release

release: ${releasetarball}

${releasetarball}: dist/VERSION dist/VERSION.hash
	@echo hereiam: `pwd`
	tar -acf $@ '--transform=s,^dist,${releasedir},' $^ \
		-T <(sed 's,.*  ,dist/,' < dist/VERSION.hash)

dist/VERSION.hash:
	$(MAKE) -C dist/ -f hash.mk VERSION.hash

clean:
	rm -rf ${releasetarball} ${releasedir} dist/VERSION.hash

test:
	./test/all.sh

test-debug:
	./test/all.sh --debug

.PHONY: all release clean test test-debug
