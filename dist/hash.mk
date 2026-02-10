SHELL:=/bin/bash

build-dir?=.
build-dirs:=${shell find ${build-dir} -type d | sort}

dot-makes:=${shell find ${build-dir} -name '*.mk' -type f | sort}
dot-make-names:=${dot-makes:${build-dir}/%=%}

# If a file or subdirectory gets created or removed, we can notice it by
# checking directory modification times.
${build-dir}/local.hash: ${build-dirs}

${build-dir}/local.hash: ${dot-makes}
	# Hash each of the files so that we can see what changed file-by-file. This
	# will support reporting local modifications file-by-file.
	{ cd ${build-dir} ; md5sum ${dot-make-names} ; } > $@

${build-dir}/VERSION.hash: ${build-dir}/local.hash
	cp $^ $@
