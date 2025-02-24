#!/bin/bash

set -e  # Exit on error

# Install Datadog CLI
echo "Installing Datadog CLI..."
npm install -g @datadog/datadog-ci

# Download the latest Datadog OSV Scanner:
# https://github.com/DataDog/osv-scanner/releases
echo "Installing DataDog SBOM generator..."
DATADOG_OSV_SCANNER_URL=https://github.com/DataDog/osv-scanner/releases/latest/download/osv-scanner_linux_amd64.zip

# Install OSV Scanner
mkdir /osv-scanner
curl -L -o /osv-scanner/osv-scanner.zip $DATADOG_OSV_SCANNER_URL
unzip /osv-scanner/osv-scanner.zip -d /osv-scanner
chmod 755 /osv-scanner/osv-scanner

# Install Python and pip (for Python dependencies)
echo "Installing Python..."
apt-get update
apt-get install -y python3 python3-pip

echo "Installation of dependencies complete."
