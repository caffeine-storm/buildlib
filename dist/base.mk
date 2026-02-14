SHELL:=/bin/bash

# A base Makefile to be used when embedding buildlib. Expects to be invoked
# from the root directory of a Go project. You can either reference this file
# by passing a '-f' flag to make while setting 'buildlib-dir' appropriately or,
# when following the recommended approach, copy this file to your root
# directory and name it 'Makefile'.

.PHONY: all
all: build-check 

buildlib-dir?=build
include ${buildlib-dir}/testing-env.mk
include ${buildlib-dir}/test-report.mk
include ${buildlib-dir}/gofumpt.mk

.PHONY: build-check
build-check:
	go build ./...

.PHONY: fmt
fmt: gofmt

.PHONY: checkfmt
checkfmt: checkgofmt

.PHONY: lint
lint:
	go run github.com/mgechev/revive@v1.5.1 ./...

.PHONY: clean
clean:
