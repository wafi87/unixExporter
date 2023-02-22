#!/bin/bash

# Set the path to the Unix exporter directory
EXPORTER_DIR="/etc/unixExporter"

# Define usage function
function usage {
  echo "Usage: $0 [-installType client|server] [-help]"
  echo "Options:"
  echo "  -installType  Install either the client or server script"
  echo "  -help         Display this help message"
  exit 1
}

# Parse command line options
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -installType)
      INSTALL_TYPE="$2"
      shift
      ;;
    -help)
      usage
      ;;
    *)
      usage
      ;;
  esac
  shift
done

# Validate install type
if [[ "$INSTALL_TYPE" != "client" && "$INSTALL_TYPE" != "server" ]]; then
  usage
fi

# Set the name and URL of the script to install
SCRIPT_NAME="receiver.sh"
SCRIPT_URL="https://raw.githubusercontent.com/username/repo/main/receiver.sh"
if [[ "$INSTALL_TYPE" == "client" ]]; then
  SCRIPT_NAME="sender.sh"
  SCRIPT_URL="https://raw.githubusercontent.com/username/repo/main/sender.sh"
fi

# Download the script to the Unix exporter directory
sudo curl -o "$EXPORTER_DIR/$SCRIPT_NAME" "$SCRIPT_URL"

# Set the executable flag on the script
sudo chmod +x "$EXPORTER_DIR/$SCRIPT_NAME"

# Modify the script with the certificate details
sudo sed -i "s/COUNTRY_NAME/$CERT_C/g" "$EXPORTER_DIR/$SCRIPT_NAME"
sudo sed -i "s/STATE_NAME/$CERT_ST/g" "$EXPORTER_DIR/$SCRIPT_NAME"
sudo sed -i "s/LOCALITY_NAME/$CERT_L/g" "$EXPORTER_DIR/$SCRIPT_NAME"
sudo sed -i "s/ORGANIZATION_NAME/$CERT_O/g" "$EXPORTER_DIR/$SCRIPT_NAME"
sudo sed -i "s/ORGANIZATIONAL_UNIT_NAME/$CERT_OU/g" "$EXPORTER_DIR/$SCRIPT_NAME"

# Inform the user that the installation was successful
echo "Installation of $SCRIPT_NAME completed successfully."
