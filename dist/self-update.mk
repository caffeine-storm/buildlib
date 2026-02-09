SHELL:=/bin/bash

base-rev-version:=${file <VERSION}
base-rev-major-version:=$(firstword $(subst ., ,${base-rev-version}))
base-rev-hash:=${file <VERSION.hash}

ifneq (,$(findstring s,${MAKEFLAGS}))
silence:=-s
endif

# Guard against weirdness by only running self-update if we're in a directory
# called "build". It's "dist" in buildlib's source-control and users can
# disable self-update by _not_ renaming the directory created by extracting the
# tarball.
live-dir:=${shell basename $(realpath .)}
ifneq "${live-dir}" "build"
$(error "self-update is disabled unless the containing directory is called 'build'")
endif

# For tests, we can use '.' for fetching tag info just from the local git repo.
# repo-url?=https://github.com/caffeine-storm/buildlib
repo-url?=.

list-major-version-tags:=git ls-remote --tags "${repo-url}" 'v${base-rev-major-version}\.*'
git-tag-to-version:=sed -e 's,.*/\(v[0-9.]*\)^{}$$,\1,'
order-by-version-descending:=sort -Vr
take-first:=head -1
repo-latest-version=$(shell ${list-major-version-tags} | ${git-tag-to-version} | ${order-by-version-descending} | ${take-first})

# TODO(tmckee): stubbing upstream tarball fetch until we figure out release
# strategy. After that, we can add CI to buildlib. The tests can also specify a
# specific upstream_url to use thereby avoiding a network fetch during test.
upstream_url?=file://$(abspath ./../../buildlib-v0.0.2.tar.gz)

self-update: no-local-changes
	curl ${silence} -L ${upstream_url} -o buildlib-upstream.tar.gz
	tar -xf buildlib-upstream.tar.gz --wildcards '*/VERSION' -O > VERSION.upstream
	# Only 'promote' the tarball if the upstream version is greater-than the
	# local version.
	if cat VERSION VERSION.upstream | sort -Vuc &>/dev/null; then \
		newversion=$$(cat VERSION.upstream) && \
		cd .. && \
		tar -xf build/buildlib-upstream.tar.gz && \
		mv build/ buildlib-v$${newversion}/build.old && \
		mv buildlib-v$${newversion} build ; \
	else \
		echo "no update needed" ; \
	fi

include hash.mk
no-local-changes: |local.hash
	# To make sure we don't clobber changes made to a-copy-of a release, check
	# file contents against a hash value included in the distribution.
	@diff -q local.hash VERSION.hash || { echo ' !! detected local modifications; refusing to update' ; false ; }

.PHONY: no-local-changes
