SHELL:=/bin/bash

version:=${file <dist/VERSION}
releasedir:=buildlib-v${version}
releasetarball:=${releasedir}.tar.gz

all: ${releasetarball}

release: ${releasetarball} test

${releasetarball}: dist/VERSION dist/VERSION.hash
	tar -acf $@ '--transform=s,^dist,${releasedir},' $^ \
		-T <(sed 's,.*  ,dist/,' < dist/VERSION.hash)

# Always delegate to hash.mk to check if VERSION.hash needs to be rebuilt.
.PHONY: dist/VERSION.hash
dist/VERSION.hash:
	$(MAKE) -C dist/ -f hash.mk VERSION.hash

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
