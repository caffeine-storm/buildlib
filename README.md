# buildlib

Collection of makefiles for common helpers and patterns.

NOTE: this collection only supports GNU Make with /bin/bash as the underlying
'shell'; _not_ /bin/sh as would be the default for GNU Make.

The files to use are in the `dist/` directory. Other things are tests and
scripts for this project itself.

To build a release, run `make release`, to build the
`buildlib-<version>.tar.gz` tarball.

To use a release, download or build the `buildlib-<version>.tar.gz` and extract
it wherever you like. Keeping a copy of the files directly in the project that
uses them under a 'build/' directory is recommended. When using this approach,
you can update the buildlib you're using by running
`make -C build/ -f self-update.mk`.

To run this projects' tests, run `make test`.
