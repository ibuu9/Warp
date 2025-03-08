# Use Ubuntu 20.04 as the base image
FROM ubuntu:20.04

# Set environment variables to avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    gpg \
    lsb-release \
    dante-server \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Cloudflare WARP client
RUN curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/cloudflare-client.list \
    && apt-get update \
    && apt-get install -y cloudflare-warp \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create necessary directories and files for WARP
RUN mkdir -p /var/lib/cloudflare-warp \
    && touch /var/lib/cloudflare-warp/reg.json \
    && chmod 600 /var/lib/cloudflare-warp/reg.json

# Configure Dante SOCKS5 proxy
RUN echo -e "logoutput: syslog\n\
internal: 0.0.0.0 port = 1080\n\
external: eth0\n\
method: username\n\
user.privileged: root\n\
user.notprivileged: nobody\n\
client pass {\n\
    from: 0.0.0.0/0 to: 0.0.0.0/0\n\
    log: connect disconnect error\n\
}\n\
pass {\n\
    from: 0.0.0.0/0 to: 0.0.0.0/0\n\
    log: connect disconnect error\n\
}" > /etc/danted.conf

# Expose the SOCKS5 proxy port
EXPOSE 1080

# Start WARP and Dante SOCKS5 proxy
CMD warp-svc & \
    sleep 5 && \
    warp-cli connect && \
    danted -f /etc/danted.conf
