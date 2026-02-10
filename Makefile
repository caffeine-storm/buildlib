SHELL:=/bin/bash

version:=${file <dist/VERSION}
releasedir:=buildlib-v${version}
releasetarball:=${releasedir}.tar.gz

all: ${releasetarball}

releaseball: ${releasetarball}
release: ${releasetarball} test

${releasetarball}: dist/VERSION dist/VERSION.hash
	tar -acf $@ '--transform=s,^dist,${releasedir},' $^ \
		-T <(sed 's,.*  ,dist/,' < dist/VERSION.hash)

# Always delegate to dist/hash.mk to check if content hashes need to be
# rebuilt.
build-dir:=dist
include dist/hash.mk

clean:
	rm -rf ${releasetarball} ${releasedir} dist/VERSION.hash

test:
	./test/all.sh

test-debug:
	./test/all.sh --debug

.PHONY: release-tag
release-tag:
	git tag v${version}

.PHONY: all release clean test test-debug
