FROM rust as builder

ADD . /wasmi
WORKDIR /wasmi/fuzz

RUN apt-get update && apt-get install -y cmake clang git
RUN git apply ./cargo.patch

RUN rustup toolchain add nightly
RUN rustup default nightly
RUN cargo +nightly install -f cargo-fuzz

RUN cargo +nightly fuzz build

FROM ubuntu:20.04

COPY --from=builder /wasmi/fuzz/target/x86_64-unknown-linux-gnu/release/load /
COPY --from=builder /wasmi/fuzz/target/x86_64-unknown-linux-gnu/release/load_wabt /
COPY --from=builder /wasmi/fuzz/target/x86_64-unknown-linux-gnu/release/load_wasmparser /
COPY --from=builder /wasmi/fuzz/target/x86_64-unknown-linux-gnu/release/load_spec /
