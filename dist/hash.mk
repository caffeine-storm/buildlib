SHELL:=/bin/bash

buildlib-dir?=.
buildlib-dirs:=${shell find ${buildlib-dir} -type d | sort}

dot-makes:=${shell find ${buildlib-dir} -name '*.mk' -type f | sort}
dot-make-names:=${dot-makes:${buildlib-dir}/%=%}

# If a file or subdirectory gets created or removed, we can notice it by
# checking directory modification times.
${buildlib-dir}/local.hash: ${buildlib-dirs}

${buildlib-dir}/local.hash: ${dot-makes}
	# Hash each of the files so that we can see what changed file-by-file. This
	# will support reporting local modifications file-by-file.
	{ cd ${buildlib-dir} ; md5sum ${dot-make-names} ; } > $@

${buildlib-dir}/VERSION.hash: ${buildlib-dir}/local.hash
	cp $^ $@
