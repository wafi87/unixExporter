#!/bin/bash
# Run this script to retrieve system information, create an XML file with this information, and send it to the receiver specified in the connection.cfg file at a specified interval.



# Check if the connection.cfg file exists
if [ ! -f connection.cfg ]; then
    # If the file doesn't exist, prompt the user for the receiver's IP address and create the file
    read -p "Enter the receiver's IP address: " receiver_ip
    echo "SERVER=$receiver_ip" > connection.cfg
fi

# Read the IP address of the receiver from the connection.cfg file
source connection.cfg

# Generate a self-signed certificate and key for SSL/TLS encryption
openssl req -new -x509 -days 365 -nodes -out cert.pem -keyout key.pem -subj "/C=DE/ST=Berlin/L=Berlin/O=UnixExporter/OU=UnixExporter/CN=localhost"

# Check if the settings.cfg file exists
if [ ! -f settings.cfg ]; then
    # If the file doesn't exist, create it with the default interval of 1 hour
    echo "INTERVAL=3600" > settings.cfg
fi

# Send the settings.cfg file to the receiver on startup
openssl s_client -connect $SERVER:6601 -cert cert.pem -key key.pem < settings.cfg

# Keep track of the last modification time of the settings.cfg file
last_modified=$(stat -c %Y settings.cfg)

while true; do
    # Retrieve system information
    public_ip=$(curl -s ifconfig.me)
    private_ip=$(hostname -I | awk '{print $1}')
    os_name=$(lsb_release -d | awk '{print $2 " " $3}')
    os_version=$(lsb_release -r | awk '{print $2}')
    hostname=$(hostname)

    # Create the XML file
    echo "<system_info>" > system_info.xml
    echo "  <public_ip>$public_ip</public_ip>" >> system_info.xml
    echo "  <private_ip>$private_ip</private_ip>" >> system_info.xml
    echo "  <os_name>$os_name</os_name>" >> system_info.xml
    echo "  <os_version>$os_version</os_version>" >> system_info.xml
    echo "  <hostname>$hostname</hostname>" >> system_info.xml
    echo "</system_info>" >> system_info.xml

    # Send the XML file to the receiver specified in the connection.cfg file using SSL/TLS encryption
    openssl s_client -connect $SERVER:6601 -cert cert.pem -key key.pem < system_info.xml

    # Check if the settings.cfg file has been modified since the last time it was checked
    if [ $(stat -c %Y settings.cfg) -gt $last_modified ]; then
        # If the file has been modified, send it to the receiver and update the last modification time
        openssl s_client -connect $SERVER:6601 -cert cert.pem -key key.pem < settings.cfg
        last_modified=$(stat -c %Y settings.cfg)
    fi

    # Wait for the specified interval before sending another file
    source settings.cfg
    sleep $INTERVAL
done
