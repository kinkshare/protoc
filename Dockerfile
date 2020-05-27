ARG go=1.14.3
ARG alpine=3.11

FROM golang:$go-alpine$alpine AS build

ENV protoc_version=3.12.2

RUN set -ex && apk --update --no-cache add \
    ca-certificates \
    bash \
    curl \
    git \
    tree \
    && \
    PROTOC_DIR="/opt/protoc" && \
    mkdir -p "${PROTOC_DIR}" && \
    mkdir -p "${PROTOC_DIR}/out" && \
    curl --silent --show-error --fail --location --output "${PROTOC_DIR}/protoc.zip" "https://github.com/protocolbuffers/protobuf/releases/download/v${protoc_version}/protoc-${protoc_version}-$(uname -s)-$(uname -m).zip" && \
    unzip "${PROTOC_DIR}/protoc.zip" -d "${PROTOC_DIR}/out" && \
    go get -v google.golang.org/protobuf/cmd/protoc-gen-go && \
    tree /go && \
    tree /opt/protoc

FROM build AS protoc

COPY --from=build /opt/protoc/out/bin/protoc /usr/local/bin/protoc
COPY --from=build /opt/protoc/out/include /usr/local/protoc-include
COPY --from=build /go/bin/protoc-gen-go /usr/local/bin/protoc-gen-go

ENTRYPOINT ["protoc", "-I/usr/local/protoc-include"]
