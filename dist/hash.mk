SHELL:=/bin/bash

distdir?=.
dotmakes:=${shell find ${distdir} -name '*.mk' -type f | sort}
dotmakenames:=${dotmakes:${distdir}/%=%}

${distdir}/local.hash: ${dotmakes}
	# Hash each of the files so that we can see what changed file-by-file. This
	# will support reporting local modifications file-by-file.
	{ cd ${distdir} ; md5sum ${dotmakenames} ; } > $@

${distdir}/VERSION.hash: ${distdir}/local.hash
	cp $^ $@
