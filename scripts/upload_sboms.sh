#!/bin/bash

set -e  # Exit on error

echo "Uploading SBOMs..."

# Iterate over all SBOM files in /tmp/sboms
for file in "$SBOM_DIR"/*; do
    if [[ -f "$file" ]]; then
        # Generate a unique identifier for the file (commit SHA + file hash)
        git commit --allow-empty -m "SCA testing upload $file"

        echo "Uploading SBOM: $file"

        # Upload SBOM file using datadog-ci
        datadog-ci sbom upload "$file"
        
        echo "Successfully uploaded: $file"
    fi
done

echo "Uploads complete."