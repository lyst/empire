.PHONY: build test bootstrap

REPO = lyst/empire
TYPE ?= patch
ARTIFACTS ?= build

build_old_golang_env:
	docker build -f Dockerfile.test -t ${REPO}:test .

run_old_golang: build_old_golang_env
	docker run -it -u $(shell id -u) -v $(shell pwd):/go/src/github.com/remind101/empire ${REPO}:test

cmds: build/empire build/emp

clean:
	rm -rf build/*

build/empire:
	go build -o build/empire ./cmd/empire

build/emp:
	go build -o build/emp ./cmd/emp

bootstrap: cmds
	createdb empire || true
	./build/empire migrate

build: Dockerfile
	docker build -t ${REPO} .

test: build/emp
	go test -race $(shell go list ./... | grep -v /vendor/)
	./tests/deps

vet:
	go vet $(shell go list ./... | grep -v /vendor/)

bump:
	pip install --upgrade bumpversion
	bumpversion ${TYPE}

$(ARTIFACTS)/all: $(ARTIFACTS)/emp-Linux-x86_64 $(ARTIFACTS)/emp-Darwin-x86_64 $(ARTIFACTS)/empire-Linux-x86_64

$(ARTIFACTS)/emp-Linux-x86_64:
	env GOOS=linux go build -o $@ ./cmd/emp
$(ARTIFACTS)/emp-Darwin-x86_64:
	env GOOS=darwin go build -o $@ ./cmd/emp

$(ARTIFACTS)/empire-Linux-x86_64:
	env GOOS=linux go build -o $@ ./cmd/empire
