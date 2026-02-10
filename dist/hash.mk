SHELL:=/bin/bash

build-dir?=.
build-dirs:=${shell find ${build-dir} -type d | sort}

dotmakes:=${shell find ${build-dir} -name '*.mk' -type f | sort}
dotmakenames:=${dotmakes:${build-dir}/%=%}

# If a file or subdirectory gets created or removed, we can notice it by
# checking directory modification times.
${build-dir}/local.hash: ${build-dirs}

${build-dir}/local.hash: ${dotmakes}
	# Hash each of the files so that we can see what changed file-by-file. This
	# will support reporting local modifications file-by-file.
	{ cd ${build-dir} ; md5sum ${dotmakenames} ; } > $@

${build-dir}/VERSION.hash: ${build-dir}/local.hash
	cp $^ $@
