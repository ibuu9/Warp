# Start from an official Debian image, or any suitable base image
FROM debian:bullseye-slim

# Install required dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    ca-certificates \
    iproute2 \
    lsb-release \
    && apt-get clean

# Install the Cloudflare Warp client (warp-cli)
RUN curl -fsSL https://github.com/cloudflare/cloudflare-warp/releases/download/v2023.2.0/warp-linux-x86_64.tar.gz -o warp.tar.gz && \
    tar -xvzf warp.tar.gz && \
    mv warp /usr/local/bin/ && \
    rm warp.tar.gz

# Set environment variables (replace with your actual Warp credentials if needed)
ENV WARP_AUTH_EMAIL="your-email@example.com"  # Optional: Use if required by your Warp account
ENV WARP_AUTH_KEY="your-api-key"  # Optional: Use if required by your Warp account

# Run the Warp client
CMD warp-cli register && \
    warp-cli connect && \
    tail -f /dev/null  # Keeps the container running after Warp connects
