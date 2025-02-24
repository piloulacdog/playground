#!/bin/bash

set -e  # Exit on error

echo "Generating SBOMs..."

# Define SBOM output directory
mkdir -p "$SBOM_DIR"

# Generate SBOM with DataDog osv-scanner
echo "Scanning SBOM with datadog-sbom-generator..."
$GITHUB_WORKSPACE/osv-scanner/osv-scanner --skip-git --recursive --experimental-only-packages --no-ignore --format=cyclonedx-1-5 --output="${SBOM_DIR}/datadog-sbom-generator.json" $TARGET_DIR

echo "SBOMs generation and vulnerability scan complete."
echo "SBOMs stored at: $SBOM_DIR"