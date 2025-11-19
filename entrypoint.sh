#!/bin/bash
set -e

# Function to upload to cloud via rclone
upload_to_cloud() {
    if [ -n "$RCLONE_REMOTE" ]; then
        if [ -f "$RCLONE_CONFIG" ]; then
            echo "Uploading to cloud: $RCLONE_REMOTE"
            rclone copyto "$OUTPUT_PATH" "$RCLONE_REMOTE" --config "$RCLONE_CONFIG"
            echo "Cloud upload complete"
        else
            echo "Warning: RCLONE_REMOTE set but config not found at $RCLONE_CONFIG"
            echo "Please configure rclone via the web UI at http://localhost:5572"
        fi
    fi
}

# Function to run the m3u numberer
run_numberer() {
    if [ -z "$M3U_URL" ]; then
        echo "Error: M3U_URL environment variable is required"
        exit 1
    fi

    echo "Running m3u-channel-numberer..."
    python /app/m3u_numberer.py "$M3U_URL" -o "$OUTPUT_PATH"

    # Upload to cloud if configured
    upload_to_cloud
}

# Export the function and variables for cron
export -f run_numberer
export -f upload_to_cloud
export M3U_URL
export OUTPUT_PATH
export RCLONE_REMOTE
export RCLONE_CONFIG

if [ -n "$CRON_SCHEDULE" ]; then
    echo "Setting up cron schedule: $CRON_SCHEDULE"

    # Create cron job file
    # Pass environment variables to cron job
    cat > /etc/cron.d/m3u-numberer << EOF
SHELL=/bin/bash
M3U_URL=$M3U_URL
OUTPUT_PATH=$OUTPUT_PATH
RCLONE_REMOTE=$RCLONE_REMOTE
RCLONE_CONFIG=$RCLONE_CONFIG
$CRON_SCHEDULE root /app/run_job.sh >> /proc/1/fd/1 2>&1
EOF

    # Create the job script that cron will run
    cat > /app/run_job.sh << 'JOBEOF'
#!/bin/bash
set -e
echo "Running m3u-channel-numberer..."
python /app/m3u_numberer.py "$M3U_URL" -o "$OUTPUT_PATH"

if [ -n "$RCLONE_REMOTE" ] && [ -f "$RCLONE_CONFIG" ]; then
    echo "Uploading to cloud: $RCLONE_REMOTE"
    rclone copyto "$OUTPUT_PATH" "$RCLONE_REMOTE" --config "$RCLONE_CONFIG"
    echo "Cloud upload complete"
fi
JOBEOF
    chmod +x /app/run_job.sh

    # Set correct permissions
    chmod 0644 /etc/cron.d/m3u-numberer

    # Run once immediately on startup
    echo "Running initial execution..."
    run_numberer

    echo "Starting cron daemon..."
    cron -f
else
    # No cron schedule - run once and exit
    run_numberer
fi
