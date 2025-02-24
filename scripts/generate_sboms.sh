#!/bin/bash

set -e  # Exit on error

# Define SBOM output directory
SBOM_DIR="/tmp/sboms"
mkdir -p "$SBOM_DIR"

# Generate SBOM with DataDog osv-scanner
echo "Scanning SBOM with datadog-sbom-generator..."
/osv-scanner/osv-scanner --skip-git --recursive --experimental-only-packages --no-ignore --format=cyclonedx-1-5 --output="${SBOM_DIR}/datadog-sbom-generator.json" .

echo "SBOMs generation and vulnerability scan complete."
echo "SBOMs stored at: $SBOM_DIR"