SHELL := $(shell which bash)

.PHONY: all build

all: build

build:
	nix build --print-build-logs
