FROM golang:latest AS build
ADD . /src
WORKDIR /src
RUN apt update && apt install ca-certificates libgnutls30
RUN go get -d -v
RUN go mod vendor && go test --cover -v ./... --run UnitTest
RUN go build -v -o go-demo



FROM alpine:3.4
MAINTAINER 	Viktor Farcic <viktor@farcic.com>

RUN mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2

EXPOSE 8080
ENV DB db
CMD ["go-demo"]
HEALTHCHECK --interval=10s CMD wget -qO- localhost:8080/demo/hello

COPY --from=build /src/go-demo /usr/local/bin/go-demo
RUN chmod +x /usr/local/bin/go-demo
