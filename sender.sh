#!/bin/bash
# Run this script to retrieve system information, create an XML file with this information, and send it to the receiver specified in the connection.cfg file at a specified interval.

# Check if the connection.cfg file exists
if [ ! -f connection.cfg ]; then
    # If the file doesn't exist, prompt the user for the receiver's IP address and create the file
    read -p "Enter the receiver's IP address: " receiver_ip
    echo "SERVER=$receiver_ip" > connection.cfg
else
    # Read the IP address of the receiver from the connection.cfg file
    source connection.cfg
    receiver_ip=$(echo "$SERVER" | cut -d "=" -f 2)
fi

openssl req -new -x509 -days 365 -nodes -out cert.pem -keyout key.pem -subj "/C=DE/ST=Berlin/L=Berlin/O=UnixExporter/OU=UnixExporter/CN=$receiver_ip" -addext "subjectAltName = IP:$receiver_ip"

# Check if the settings.cfg file exists
if [ ! -f settings.cfg ]; then
    # If the file doesn't exist, create it with the default interval of 1 hour
    echo "INTERVAL=3600" > settings.cfg
fi

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
    #cat system_info.xml | openssl s_client -connect $SERVER:6601 -cert cert.pem -key key.pem -quiet

    # Wait for the specified interval before sending another file
    source settings.cfg
    sleep $INTERVAL
done
