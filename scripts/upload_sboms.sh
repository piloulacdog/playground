#!/bin/bash

set -e  # Exit on error

cd $TARGET_DIR

echo "Uploading SBOMs..."
echo "### Generated SBOM and associated SHA:" >> $GITHUB_STEP_SUMMARY

# Iterate over all SBOM files in /tmp/sboms
for file in "$SBOM_DIR"/*; do
    if [[ -f "$file" ]]; then
        echo "Uploading SBOM: $file..."

        # Generate unique SHAs even if the same repo + commit is compared twice.
        # Because we will upload one SBOM per generation tool on the same commit,
        # we force a commit SHA update, letting us upload several SBOMs. 
        LAST_COMMITTER_NAME=$(git log -1 --pretty=format:'%an')
        LAST_COMMITTER_EMAIL=$(git log -1 --pretty=format:'%ae')
        git config --global user.email "$LAST_COMMITTER_EMAIL"
        git config --global user.name "$LAST_COMMITTER_NAME"
        git commit --amend --no-edit

        # Add description to the summary of the SHA generated for a specific generation tool 
        FILENAME=$(basename "$file" .json)
        COMMIT_SHA=$(git rev-parse HEAD)
        echo "- **$FILENAME**: $COMMIT_SHA" >> $GITHUB_STEP_SUMMARY

        # Unfortunately, when executing a Github action, some git env variables cannot be overriten
        # no matter the current context of execution.
        # Assuming 2 git repositories (outer-repo and inner-repo) as follow:
        # outer-repo/
        # ├── .git/
        # ├── README.md
        # └── inner-repo/
        #     ├── .git/
        #     ├── README.md
        #     └── some-file.txt
        # Executing `datadog-ci sbom upload` at `outer-repo/` or `outer-repo/inner-repo/` would report the same result git context.
        # A workaround is to manually set DD specific env variables, that way, datadog-ci reports correct git information.
        export DD_GIT_REPOSITORY_URL=$(git config --get remote.origin.url)
        export DD_GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
        export DD_GIT_COMMIT_SHA=COMMIT_SHA
        export DD_GIT_COMMIT_MESSAGE=$(git log -1 --pretty=format:'%s')
        export DD_GIT_COMMIT_COMMITTER_DATE=$(git log -1 --pretty=format:'%cI')
        export DD_GIT_COMMIT_COMMITTER_EMAIL=$(git log -1 --pretty=format:'%ce')
        export DD_GIT_COMMIT_COMMITTER_NAME=$(git log -1 --pretty=format:'%cn')
        export DD_GIT_COMMIT_AUTHOR_DATE=$(git log -1 --pretty=format:'%aI')
        export DD_GIT_COMMIT_AUTHOR_EMAIL=$(git log -1 --pretty=format:'%ae')
        export DD_GIT_COMMIT_AUTHOR_NAME=$(git log -1 --pretty=format:'%an')

        # Upload SBOM file using datadog-ci
        datadog-ci sbom upload "$file"
        
        echo "Successfully uploaded: $file."
    fi
done

echo "Uploads complete."