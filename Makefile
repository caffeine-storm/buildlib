SHELL:=/bin/bash

version:=${file <dist/VERSION}
release-dir:=buildlib-v${version}
release-tarball:=${release-dir}.tar.gz

all: ${release-tarball}

release-ball: ${release-tarball}
release: ${release-tarball} test

${release-tarball}: dist/VERSION dist/VERSION.hash
	tar -acf $@ '--transform=s,^dist,${release-dir},' $^ \
		-T <(sed 's,.*  ,dist/,' < dist/VERSION.hash)

# Always delegate to dist/hash.mk to check if content hashes need to be
# rebuilt.
build-dir:=dist
include dist/hash.mk

clean:
	rm -rf ${release-tarball} ${release-dir} dist/VERSION.hash

test:
	./test/all.sh

test-debug:
	./test/all.sh --debug

.PHONY: release-tag
release-tag:
	git tag -s v${version}

.PHONY: all release release-ball clean test test-debug
