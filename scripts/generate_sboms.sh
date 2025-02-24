#!/bin/bash

set -e  # Exit on error

echo "Generating SBOMs..."

echo "### Tools Used for SBOM Generation:" >> $GITHUB_STEP_SUMMARY

# Define SBOM output directory
mkdir -p "$SBOM_DIR"

# Generate SBOM with DataDog osv-scanner
echo "Scanning SBOM with datadog-sbom-generator..."
echo "- datadog-sbom-generator" >> $GITHUB_STEP_SUMMARY # adding to the overall action summary
$GITHUB_WORKSPACE/osv-scanner/osv-scanner --skip-git --recursive --experimental-only-packages --no-ignore --format=cyclonedx-1-5 --output="${SBOM_DIR}/datadog-sbom-generator.json" .

echo "SBOMs generation and vulnerability scan complete."
echo "SBOMs stored at: $SBOM_DIR"