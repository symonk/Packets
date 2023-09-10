# Build Stage
FROM lacion/alpine-golang-buildimage:1.13 AS build-stage

LABEL app="build-Packets"
LABEL REPO="https://github.com/symonk/Packets"

ENV PROJPATH=/go/src/github.com/symonk/Packets

# Because of https://github.com/docker/docker/issues/14914
ENV PATH=$PATH:$GOROOT/bin:$GOPATH/bin

ADD . /go/src/github.com/symonk/Packets
WORKDIR /go/src/github.com/symonk/Packets

RUN make build-alpine

# Final Stage
FROM lacion/alpine-base-image:latest

ARG GIT_COMMIT
ARG VERSION
LABEL REPO="https://github.com/symonk/Packets"
LABEL GIT_COMMIT=$GIT_COMMIT
LABEL VERSION=$VERSION

# Because of https://github.com/docker/docker/issues/14914
ENV PATH=$PATH:/opt/Packets/bin

WORKDIR /opt/Packets/bin

COPY --from=build-stage /go/src/github.com/symonk/Packets/bin/Packets /opt/Packets/bin/
RUN chmod +x /opt/Packets/bin/Packets

# Create appuser
RUN adduser -D -g '' Packets
USER Packets

ENTRYPOINT ["/usr/bin/dumb-init", "--"]

CMD ["/opt/Packets/bin/Packets"]
