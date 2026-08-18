SHELL := /usr/bin/env bash

.PHONY: help install test doctor

help:
	@printf '%s\n' \
	  'make install  - run the full workstation bootstrap' \
	  'make test     - validate repository layout and shell syntax' \
	  'make doctor   - run ctfdoctor if installed'

install:
	./scripts/bootstrap.sh

test:
	./tests/test-layout.sh

doctor:
	@if command -v ctfdoctor >/dev/null 2>&1; then ctfdoctor; else echo 'ctfdoctor is not installed yet'; fi
