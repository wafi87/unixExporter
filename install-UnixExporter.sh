#!/bin/bash

# Set the path to the Unix exporter directory
EXPORTER_DIR="/etc/unixExporter"

# Define usage function
function usage {
  echo ""
  echo "Usage: $0 [-installType client|server] [-help]"
  echo ""
  echo "Options:"
  echo "  -installType [client|server]    | Install either the client or server script"
  echo "  -help                           | Display this help message"
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
SCRIPT_URL="https://raw.githubusercontent.com/wafi87/unixExporter/main/receiver.sh"
if [[ "$INSTALL_TYPE" == "client" ]]; then
  SCRIPT_NAME="sender.sh"
  SCRIPT_URL="https://raw.githubusercontent.com/wafi87/unixExporter/main/sender.sh"
fi

# Create the Unix exporter directory if it doesn't exist
sudo mkdir -p "$EXPORTER_DIR"

# Download the script to the Unix exporter directory
sudo wget -O "$EXPORTER_DIR/$SCRIPT_NAME" "$SCRIPT_URL"

# Set the executable flag on the script
sudo chmod +x "$EXPORTER_DIR/$SCRIPT_NAME"

# Start the script
"$EXPORTER_DIR/$SCRIPT_NAME"
