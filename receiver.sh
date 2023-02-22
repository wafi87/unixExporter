#!/bin/bash

# Check if the connection.cfg file exists
if [ ! -f connection.cfg ]; then
    # If the file doesn't exist, create it with the default IP address of localhost
    echo "IP_ADDRESS=localhost" > connection.cfg
fi

# Generate a self-signed certificate and key for SSL/TLS encryption
openssl req -new -x509 -days 365 -nodes -out cert.pem -keyout key.pem -subj "/C=DE/ST=Berlin/L=Berlin/O=UnixExporter/OU=UnixExporter/CN=192.168.229.102"

# Read the IP address of the sender from the connection.cfg file
source connection.cfg

# Wait for an incoming connection on port 6601
echo "Waiting for incoming data..."
    # Wait for an incoming connection on port 6601
    filename=$(date +%Y%m%d%H).xml
    
    # Use grep to extract the XML data
openssl s_server -accept 6601 -cert cert.pem -key key.pem -quiet > $filename
done
