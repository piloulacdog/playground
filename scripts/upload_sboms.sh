#!/bin/bash

set -e  # Exit on error

echo "Uploading SBOMs..."

# Iterate over all SBOM files in /tmp/sboms
for file in "$SBOM_DIR"/*; do
    if [[ -f "$file" ]]; then
        # Generate unique SHAs even if the same repo + commit is compared twice, that is irrelevant here
        LAST_COMMITTER_NAME=$(git log -1 --pretty=format:'%an')
        LAST_COMMITTER_EMAIL=$(git log -1 --pretty=format:'%ae')
        git config --global user.email "$LAST_COMMITTER_EMAIL"
        git config --global user.name "$LAST_COMMITTER_NAME"
        git commit --amend --no-edit

        echo "Uploading SBOM: $file"

        # Upload SBOM file using datadog-ci
        datadog-ci sbom upload "$file"
        
        echo "Successfully uploaded: $file"
    fi
done

echo "Uploads complete."