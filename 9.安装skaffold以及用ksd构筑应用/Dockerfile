FROM golang:1.15 as builder
WORKDIR /go/src/github.com/owner/repo
ENV GO111MODULE="on"
ENV CGO_ENABLED=0 
COPY . . 
RUN go build -o server main.go

FROM alpine
RUN apk add --no-cache ca-certificates
COPY --from=builder /go/src/github.com/owner/repo/server  /go/bin/server
WORKDIR /go/bin/
