SHELL:=/bin/bash

version:=${file <dist/VERSION}
releasedir:=buildlib-v${version}
releasetarball:=${releasedir}.tar.gz

# TODO(tmckee): this is almost-copy-paste from dist/hash.mk ... DRY this out.
dotmakes:=${shell find dist/ -name '*.mk' -type f | sort}

all: release

release: ${releasetarball}

${releasetarball}: ${dotmakes} dist/VERSION dist/VERSION.hash
	tar -acf $@ '--transform=s,^dist,${releasedir},' $^

dist/VERSION.hash: ${dotmakes}
	make -C dist/ -f hash.mk local.hash
	mv dist/local.hash dist/VERSION.hash

clean:
	rm -rf ${releasetarball} ${releasedir} dist/VERSION.hash

test:
	./test/all.sh

test-debug:
	./test/all.sh --debug

.PHONY: all release clean test test-debug
