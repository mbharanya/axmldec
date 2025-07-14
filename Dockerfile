# Use a base image with build tools
FROM ubuntu:22.04 AS builder

# Install dependencies, including ca-certificates for git
RUN apt-get update && \
    apt-get install -y \
    git \
    ca-certificates \
    cmake \
    build-essential \
    libboost-all-dev \
    zlib1g-dev \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# Clone the repository
RUN git clone --recursive https://github.com/ytsutano/axmldec.git /axmldec

# Build the tool
WORKDIR /axmldec
RUN cmake -DCMAKE_BUILD_TYPE=Release . && make

# Create a smaller final image
FROM ubuntu:22.04
RUN apt-get update && \
    apt-get install -y \
    libboost-system1.74.0 \
    libboost-filesystem1.74.0 \
    libboost-iostreams1.74.0 \
    libboost-program-options1.74.0 \
    zlib1g \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /axmldec/axmldec /usr/local/bin/axmldec

# Set the entrypoint to the axmldec executable
ENTRYPOINT ["/usr/local/bin/axmldec"]

# By default, show the help message
CMD ["--help"]
