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
    && touch /var/lib/cloudflare-warp/settings.json \
    && touch /var/lib/cloudflare-warp/consumer-settings.json \
    && chmod 600 /var/lib/cloudflare-warp/reg.json \
    && chmod 600 /var/lib/cloudflare-warp/settings.json \
    && chmod 600 /var/lib/cloudflare-warp/consumer-settings.json

# Configure Dante SOCKS5 proxy using heredoc
RUN bash -c 'cat <<EOF > /etc/danted.conf
logoutput: syslog
internal: 0.0.0.0 port = 1080
external: eth0
method: username
user.privileged: root
user.notprivileged: nobody
client pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    log: connect disconnect error
}
pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    log: connect disconnect error
}
EOF'

# Expose the SOCKS5 proxy port
EXPOSE 1080

# Start WARP and Dante SOCKS5 proxy
CMD warp-svc & \
    sleep 5 && \
    warp-cli connect && \
    danted -f /etc/danted.conf
