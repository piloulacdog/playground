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

        # export GIT_DIR="$TARGET_DIR/.git"
        echo "Current directory: $(pwd)"
        git config --local --list

        export DD_GIT_REPOSITORY_URL=$(git config --get remote.origin.url)
        export DD_GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
        export DD_GIT_COMMIT_SHA=$(git rev-parse HEAD)
        export DD_GIT_COMMIT_MESSAGE=$(git log -1 --pretty=format:'%s')
        export DD_GIT_COMMIT_COMMITTER_DATE=$(git log -1 --pretty=format:'%cI')
        export DD_GIT_COMMIT_COMMITTER_EMAIL=$(git log -1 --pretty=format:'%ce')
        export DD_GIT_COMMIT_COMMITTER_NAME=$(git log -1 --pretty=format:'%cn')
        export DD_GIT_COMMIT_AUTHOR_DATE=$(git log -1 --pretty=format:'%aI')
        export DD_GIT_COMMIT_AUTHOR_EMAIL=$(git log -1 --pretty=format:'%ae')
        export DD_GIT_COMMIT_AUTHOR_NAME=$(git log -1 --pretty=format:'%an')

        echo "DD_GIT_REPOSITORY_URL: $DD_GIT_REPOSITORY_URL"
        echo "DD_GIT_BRANCH: $DD_GIT_BRANCH"
        echo "DD_GIT_COMMIT_SHA: $DD_GIT_COMMIT_SHA"
        echo "DD_GIT_TAG: $DD_GIT_TAG"
        echo "DD_GIT_COMMIT_MESSAGE: $DD_GIT_COMMIT_MESSAGE"
        echo "DD_GIT_COMMIT_COMMITTER_DATE: $DD_GIT_COMMIT_COMMITTER_DATE"
        echo "DD_GIT_COMMIT_COMMITTER_EMAIL: $DD_GIT_COMMIT_COMMITTER_EMAIL"
        echo "DD_GIT_COMMIT_COMMITTER_NAME: $DD_GIT_COMMIT_COMMITTER_NAME"
        echo "DD_GIT_COMMIT_AUTHOR_DATE: $DD_GIT_COMMIT_AUTHOR_DATE"
        echo "DD_GIT_COMMIT_AUTHOR_EMAIL: $DD_GIT_COMMIT_AUTHOR_EMAIL"
        echo "DD_GIT_COMMIT_AUTHOR_NAME: $DD_GIT_COMMIT_AUTHOR_NAME"

        # Upload SBOM file using datadog-ci
        datadog-ci sbom upload "$file"
        
        echo "Successfully uploaded: $file."
    fi
done

echo "Uploads complete."