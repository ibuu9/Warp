# Start from an official Debian image
FROM debian:bullseye-slim

# Install required dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    ca-certificates \
    iproute2 \
    lsb-release \
    && apt-get clean

# Install Cloudflare Warp client (warp-cli)
RUN curl -fsSL https://github.com/cloudflare/cloudflare-warp/releases/download/v2023.2.0/warp-linux-x86_64.tar.gz -o warp.tar.gz && \
    tar -xvzf warp.tar.gz && \
    mv warp /usr/local/bin/ && \
    rm warp.tar.gz

# Optional: Set environment variables (you can remove these if you are not using authentication)
ENV WARP_AUTH_EMAIL="your-email@example.com"
ENV WARP_AUTH_KEY="your-api-key"

# Run the Warp client and keep the container running
CMD warp-cli register && \
    warp-cli connect && \
    tail -f /dev/null
