#!/bin/bash
set -e

# Default username (must match Dockerfile)
USERNAME="naisr"

# Ensure UID and GID are provided via environment variables
if [ -z "$USER_UID" ] || [ -z "$USER_GID" ]; then
    echo "WARNING: USER_UID or USER_GID not provided, keeping default UID/GID."
else
    # Check if current UID/GID need adjustment
    CURRENT_UID=$(id -u "$USERNAME")
    CURRENT_GID=$(id -g "$USERNAME")

    echo "Changing Permissions."
    echo "Current Username: $USERNAME"
    echo "Current UID and GID: $CURRENT_UID and $CURRENT_GID"
    echo "Desired UID and GID: $USER_UID and $USER_GID"
    
    if [ "$CURRENT_UID" != "$USER_UID" ] || [ "$CURRENT_GID" != "$USER_GID" ]; then
        # Adjust group GID
        sudo groupmod -g "$USER_GID" "$USERNAME"
        # Adjust user UID and GID
        sudo usermod -u "$USER_UID" -g "$USER_GID" "$USERNAME"
        # Fix home directory ownership
        sudo chown -R "$USER_UID:$USER_GID" "/home/$USERNAME"
    fi
    # Fix workspace directory ownership    
    sudo chown -R "$USER_UID:$USER_GID" "/naisr2_ws"
fi

echo "Container ready."
# Execute the command as the adjusted user
exec "$@"