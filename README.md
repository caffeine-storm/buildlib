# buildlib

Collection of makefiles for common helpers and patterns.

The files to use are in the `dist/` directory. Other things are tests and
scripts for this project itself.

To build a release, run `make release`, to build the
`buildlib-<version>.tar.gz` tarball.

To use a release, download or build the `buildlib-<version>.tar.gz` and extract
it wherever you like. Keeping a copy of the files directly in the project that
uses them under a 'build/' directory is recommended.

To run this projects' tests, run `make test`.
