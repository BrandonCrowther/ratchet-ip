FROM python:3.11-slim

# Install required packages: aws-cli, cron, curl
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    cron \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install AWS CLI v2
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
        AWS_CLI_ARCH="x86_64"; \
    elif [ "$ARCH" = "aarch64" ]; then \
        AWS_CLI_ARCH="aarch64"; \
    else \
        echo "Unsupported architecture: $ARCH" && exit 1; \
    fi && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-${AWS_CLI_ARCH}.zip" -o "awscliv2.zip" && \
    apt-get update && apt-get install -y unzip && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip aws && \
    apt-get remove -y unzip && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /app

# Copy scripts
COPY scripts/update-ip.sh /app/update-ip.sh
COPY scripts/entrypoint.sh /app/entrypoint.sh

# Make scripts executable
RUN chmod +x /app/update-ip.sh /app/entrypoint.sh

# Create directory for IP storage
RUN mkdir -p /var/ratchet-ip

# Set up the entrypoint
ENTRYPOINT ["/app/entrypoint.sh"]
