.EXPORT_ALL_VARIABLES:

SHELL=/bin/bash -o pipefail

check:
	shellcheck libcnb.bash

test:
	bats test.bats

.PHONY: check
