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
mkdir -p $GITHUB_WORKSPACE/osv-scanner
curl -L -o $GITHUB_WORKSPACE/osv-scanner/osv-scanner.zip $DATADOG_OSV_SCANNER_URL
unzip $GITHUB_WORKSPACE/osv-scanner/osv-scanner.zip -d $GITHUB_WORKSPACE/osv-scanner
chmod 755 $GITHUB_WORKSPACE/osv-scanner/osv-scanner

# Install Python and pip (for Python dependencies)
echo "Installing Python..."
echo "$(python3 --version)"

echo "Installation of dependencies complete."
