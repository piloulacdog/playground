#!/bin/bash

set -e  # Exit on error

echo "Uploading SBOMs..."
echo "### Generated SBOM and associated SHA:" >> $GITHUB_STEP_SUMMARY

# Iterate over all SBOM files in /tmp/sboms
for file in "$SBOM_DIR"/*; do
    if [[ -f "$file" ]]; then
        echo "Uploading SBOM: $file..."

        # Generate unique SHAs even if the same repo + commit is compared twice, that is irrelevant here
        LAST_COMMITTER_NAME=$(git log -1 --pretty=format:'%an')
        LAST_COMMITTER_EMAIL=$(git log -1 --pretty=format:'%ae')
        git config --global user.email "$LAST_COMMITTER_EMAIL"
        git config --global user.name "$LAST_COMMITTER_NAME"
        git commit --amend --no-edit

        FILENAME=$(basename "$file" .json)
        COMMIT_SHA="${GITHUB_SHA}"
        echo "- **$FILENAME**: $COMMIT_SHA" >> $GITHUB_STEP_SUMMARY

        CURRENT_REPO=$(git remote get-url origin)
        echo "Current repository: $CURRENT_REPO"
        CURRENT_SHA=$(git rev-parse HEAD)
        echo "Current commit SHA: $CURRENT_SHA"

        # Upload SBOM file using datadog-ci
        datadog-ci sbom upload "$file"
        
        echo "Successfully uploaded: $file."
    fi
done

echo "Uploads complete."