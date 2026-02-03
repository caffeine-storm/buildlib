SHELL:=/bin/bash

dotmakes:=${shell find . -name '*.mk' -type f | sort}

local.hash: ${dotmakes}
	# Hash each file so that we can detect add/remove conflicts.
	md5sum $^ > $@
