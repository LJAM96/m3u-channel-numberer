FROM python:3.12-slim

# Install cron and rclone
RUN apt-get update && apt-get install -y --no-install-recommends \
    cron \
    curl \
    unzip \
    && ARCH=$(dpkg --print-architecture) \
    && if [ "$ARCH" = "amd64" ]; then RCLONE_ARCH="amd64"; \
       elif [ "$ARCH" = "arm64" ]; then RCLONE_ARCH="arm64"; \
       else RCLONE_ARCH="amd64"; fi \
    && curl -O https://downloads.rclone.org/rclone-current-linux-${RCLONE_ARCH}.zip \
    && unzip rclone-current-linux-${RCLONE_ARCH}.zip \
    && cp rclone-*-linux-${RCLONE_ARCH}/rclone /usr/bin/ \
    && chmod 755 /usr/bin/rclone \
    && rm -rf rclone-* \
    && apt-get remove -y curl unzip \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /app

# Copy application files
COPY m3u_numberer.py .
COPY entrypoint.sh .

# Make entrypoint executable
RUN chmod +x entrypoint.sh

# Create data directory for output
RUN mkdir -p /data

# Environment variables
ENV M3U_URL=""
ENV CRON_SCHEDULE=""
ENV OUTPUT_PATH="/data/numbered_playlist.m3u"
ENV RCLONE_REMOTE=""
ENV RCLONE_CONFIG="/config/rclone/rclone.conf"

VOLUME /data

ENTRYPOINT ["/app/entrypoint.sh"]
