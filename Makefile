ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
BIN_DIR = $(ROOT_DIR)/bin
PROJ_NAME = yace
VERSION ?= $(or $(shell git tag --sort=creatordate | grep -E '[0-9]' | tail -1 | cut -b 2-7 | awk -F. '{$$NF = $$NF + 1;} 1' | sed 's/ /./g'), $(shell echo 0.0.1))
PACKAGES = $$(go list ./... | grep -v '/vendor/')

help: _help_

_help_:
	@echo make fmt - fix formatting for the all files in the project
	@echo make build - build and push release with goreleaser. Output folder ./dist
	@echo make test - run tests
	@echo make lint - run golangci-lint to check code
	@echo make deps - install or upgrade dependencies

.DEFAULT_GOAL := build

.PHONY: build test lint
build:
	go build -v -o $(BIN_DIR)/$(PROJ_NAME) ./cmd/yace

test:
	go test -timeout=15m -race -coverprofile=coverage.out -covermode=atomic -cover $(PACKAGES)

lint:
	golangci-lint run -v -c .golangci.yml

deps:
	go get -u github.com/golangci/golangci-lint/cmd/golangci-lint

fmt:
	go fmt ./...

vet:
	go vet ./...

version:
	@echo $(VERSION)

coverage: test
	go tool cover -html=coverage.out

# Upgrade all dependencies to the latest version
upgrade-deps:
	go get -u -t -d -v ./...