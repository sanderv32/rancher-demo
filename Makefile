CGO_ENABLED=0
GOOS=linux
GOARCH=amd64
TAG?=latest
REPO=bashofmann/rancher-demo
GO111MODULE=on

all: build

test:
	@go test -v .

binary:
	@go build -ldflags '-w -linkmode external -extldflags -static' -o rancher-demo .

build:
	@docker build -t ${REPO}:${TAG} .

.PHONY: build binary
