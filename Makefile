SHELL:=/bin/bash

version:=${file <dist/VERSION}
release-dir:=buildlib-v${version}
release-tarball:=${release-dir}.tar.gz

.PHONY: all
all: ${release-tarball}

.PHONY: release-ball
release-ball: ${release-tarball}

.PHONY: release
release: ${release-tarball} test

${release-tarball}: dist/VERSION dist/VERSION.hash
	tar -acf $@ '--transform=s,^dist,${release-dir},' $^ \
		-T <(sed 's,.*  ,dist/,' < dist/VERSION.hash)

# Always delegate to dist/hash.mk to check if content hashes need to be
# rebuilt.
build-dir:=dist
include dist/hash.mk

.PHONY: clean
clean:
	rm -rf ${release-tarball} ${release-dir} dist/VERSION.hash

.PHONY: test
test:
	./test/all.sh

.PHONY: test-debug
test-debug:
	./test/all.sh --debug

.PHONY: release-tag
release-tag:
	git tag --sign v${version}
