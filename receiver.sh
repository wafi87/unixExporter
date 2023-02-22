#!/bin/bash

receiver_ip=$(hostname -I)

# Generate a self-signed certificate and key for SSL/TLS encryption
openssl req -new -x509 -days 365 -nodes -out cert.pem -keyout key.pem -subj /C=DE/ST=Berlin/L=Berlin/O=UnixExporter/OU=UnixExporter/CN=$receiver_ip" -addext "subjectAltName = IP:$receiver_ip

# Read the IP address of the sender from the connection.cfg file
source connection.cfg

# Wait for an incoming connection on port 6601
echo "Waiting for incoming data..."
    # Wait for an incoming connection on port 6601
    filename=$(date +%Y%m%d%H).xml
    
    # Use grep to extract the XML data
openssl s_server -accept 6601 -cert cert.pem -key key.pem -quiet > $filename
done
