#!/bin/bash
# Run this script to receive XML files sent over a secure TCP connection and save them to disk

# Generate a self-signed certificate and key for SSL/TLS encryption
openssl req -new -x509 -days 365 -nodes -out cert.pem -keyout key.pem -subj "/C=DE/ST=Berlin/L=Berlin/O=UnixExporter/OU=UnixExporter/CN=localhost"

# Check if the connection.cfg file exists
if [ ! -f connection.cfg ]; then
    # If the file doesn't exist, create it with the default IP address of localhost
    echo "IP_ADDRESS=localhost" > connection.cfg
fi

# Read the IP address of the sender from the connection.cfg file
source connection.cfg

# Check if the interval.cfg file exists
if [ ! -f interval.cfg ]; then
    # If the file doesn't exist, create it with the default interval of 1 hour
    echo "INTERVAL=3600" > interval.cfg
fi

# Keep track of the last modification time of the interval.cfg file
last_modified=$(stat -c %Y interval.cfg)

# Listen on port 6601 for incoming connections and save any XML files received
while true; do
    # Check if the interval.cfg file has been modified since the last time it was checked
    if [ $(stat -c %Y interval.cfg) -gt $last_modified ]; then
        # If the file has been modified, read the new interval and update the last modification time
        source interval.cfg
        last_modified=$(stat -c %Y interval.cfg)
    fi

    # Wait for an incoming connection on port 6601
    openssl s_server -accept 6601 -cert cert.pem -key key.pem | while true; do
        # Save the incoming data to an XML file with a unique filename
        filename=$(date +%Y%m%d%H%M%S).xml
        cat > $filename

        # Wait for the specified interval before accepting another connection
        sleep $INTERVAL
    done
done
