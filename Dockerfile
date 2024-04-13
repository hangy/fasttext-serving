ARG DEBIAN_STABLE=bookworm

FROM rust:${DEBIAN_STABLE} AS rust-base
FROM rust-base AS build-env

RUN --mount=type=cache,id=apt-cache,target=/var/cache/apt set -x && \
    apt update && \
    apt install -y \
    protobuf-compiler

WORKDIR /app
COPY . /app
RUN --mount=type=cache,target=/usr/local/cargo,from=rust-base,source=/usr/local/cargo \
    cargo build --release --locked

FROM debian:${DEBIAN_STABLE}-slim

COPY --from=build-env /app/target/release/fasttext-serving /usr/bin/fasttext-serving

ENTRYPOINT ["/usr/bin/fasttext-serving"]
