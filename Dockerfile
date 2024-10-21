FROM node:16 AS ui

WORKDIR /usr/src/app
COPY . /usr/src/app
WORKDIR /usr/src/app/ui
RUN npm install
WORKDIR /usr/src/app
RUN cp -f ui/semantic.theme.config ui/semantic/src/theme.config && \
    mkdir -p ui/semantic/src/themes/app && \
    cp -rf ui/semantic.theme/* ui/semantic/src/themes/app
WORKDIR /usr/src/app/ui/semantic
RUN npx gulp build

FROM golang:1.16-alpine AS app
RUN apk add -U --no-cache build-base git
COPY . /go/src/app
WORKDIR /go/src/app
ENV GO111MODULE=on
RUN go build -a -v -tags 'netgo' -ldflags '-w -linkmode external -extldflags -static' -o rancher-demo .

FROM alpine:latest
RUN addgroup -g 1000 demo && adduser -D -u 1000 -G demo demo
USER demo
COPY --chown=demo:demo static /static
COPY --from=ui --chown=demo:demo /usr/src/app/ui/semantic/dist/semantic.min.css /static/dist/semantic.min.css
COPY --from=ui --chown=demo:demo /usr/src/app/ui/semantic/dist/semantic.min.js /static/dist/semantic.min.js
COPY --from=ui --chown=demo:demo /usr/src/app/ui/semantic/dist/themes/default/assets /static/dist/themes/default/
COPY --from=app --chown=demo:demo /go/src/app/rancher-demo /bin/rancher-demo
COPY --chown=demo:demo /templates /templates
EXPOSE 8080
ENTRYPOINT ["/bin/rancher-demo"]
