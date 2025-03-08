# Use a minimal base image
FROM debian:bullseye-slim

# Install required dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    ca-certificates \
    iproute2 \
    lsb-release \
    && apt-get clean

# Test if we can reach the URL (ping or curl the release URL)
RUN curl -fsSL https://github.com/cloudflare/cloudflare-warp/releases/download/v2023.2.0/warp-linux-x86_64.tar.gz -o /tmp/warp.tar.gz || echo "Failed to download the file."

# Install Cloudflare Warp client (warp-cli)
RUN curl -fsSL https://github.com/cloudflare/cloudflare-warp/releases/download/v2023.2.0/warp-linux-x86_64.tar.gz -o /tmp/warp.tar.gz && \
    tar -xvzf /tmp/warp.tar.gz -C /tmp && \
    mv /tmp/warp /usr/local/bin/ && \
    rm /tmp/warp.tar.gz

# Verify if Warp was installed successfully
RUN warp --version

# Set environment variables (optional if authentication needed)
ENV WARP_AUTH_EMAIL="your-email@example.com"
ENV WARP_AUTH_KEY="your-api-key"

# Ensure we can run Warp commands (optional: for debugging)
RUN warp-cli --help

# Run Warp client and keep the container running
CMD warp-cli register && \
    warp-cli connect && \
    tail -f /dev/null
