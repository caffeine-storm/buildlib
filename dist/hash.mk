SHELL:=/bin/bash

distdir?=.
distdirs:=${shell find ${distdir} -type d | sort}

dotmakes:=${shell find ${distdir} -name '*.mk' -type f | sort}
dotmakenames:=${dotmakes:${distdir}/%=%}

# If a file or subdirectory gets created or removed, we can notice it by
# checking directory modification times.
${distdir}/local.hash: ${distdirs}

${distdir}/local.hash: ${dotmakes}
	# Hash each of the files so that we can see what changed file-by-file. This
	# will support reporting local modifications file-by-file.
	{ cd ${distdir} ; md5sum ${dotmakenames} ; } > $@

${distdir}/VERSION.hash: ${distdir}/local.hash
	cp $^ $@
