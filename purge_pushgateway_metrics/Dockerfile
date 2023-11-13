# stage 1
FROM golang as golang-builder

WORKDIR /go/src/github.com/tainguyenbp/purge_pushgateway_metrics

COPY . .

# RUN go build -o purge_pushgateway_metrics .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o purge_pushgateway_metrics .

# stage 2
FROM alpine:3.18.4
RUN apk update --allow-untrusted \
    && apk --no-cache add ca-certificates \
    && rm -rf /var/cache/apk/*

LABEL author="tainguyenbp"

# WORKDIR /roaot/
COPY --from=golang-builder /go/src/github.com/tainguyenbp/purge_pushgateway_metrics/purge_pushgateway_metrics /opt/purge_pushgateway_metrics

# CMD [ "/opt/purge_pushgateway_metrics" ]
ENTRYPOINT [ "/opt/purge_pushgateway_metrics" ]
