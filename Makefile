CGO_ENABLED=0
GOOS=linux
GOARCH=amd64
TAG?=latest
REPO=bashofmann/rancher-demo
GO111MODULE=on

GIT_TREE_STATE=$(shell (git status --porcelain | grep -q .) && echo dirty || echo clean)

all: build

test:
	@go test -v .

binary:
	@go build -ldflags '-w -linkmode external -extldflags -static' -o rancher-demo .

build:
	@docker build -t ${REPO}:${TAG} .

release:
	ifeq ($(GIT_TREE_STATE),dirty)
		$(error git state is not clean)
	endif
	echo foo

.PHONY: build binary release
