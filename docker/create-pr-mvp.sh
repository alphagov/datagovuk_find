#!/bin/bash
set -e
# Script to create PR in govuk-dgu-charts for main-mvp branch
# This script updates the Find image SHA in the main-mvp branch of govuk-dgu-charts
# Check required environment variables
if [ -z "$GH_TOKEN" ]; then
  echo "Error: GH_TOKEN environment variable is required"
  exit 1
fi
if [ -z "$GH_REF" ]; then
  echo "Error: GH_REF environment variable is required"
  exit 1
fi
# Configuration
CHARTS_REPO="alphagov/govuk-dgu-charts"
CHARTS_BRANCH="main-mvp"
APP_NAME="datagovuk_find"
WORKSPACE_DIR="/tmp/govuk-dgu-charts-mvp"
echo "Configuration:"
echo "   Charts Repo: $CHARTS_REPO"
echo "   Target Branch: $CHARTS_BRANCH"
echo "   App Name: $APP_NAME"
echo "   Git Ref: $GH_REF"
# Get the image SHA from the current commit
IMAGE_SHA=$(git rev-parse HEAD)
echo "Current commit SHA: $IMAGE_SHA"
# Clean up any previous workspace
if [ -d "$WORKSPACE_DIR" ]; then
  echo "Cleaning up previous workspace"
  rm -rf "$WORKSPACE_DIR"
fi
# Clone the govuk-dgu-charts repository
echo "Cloning $CHARTS_REPO..."
git clone "https://x-access-token:${GH_TOKEN}@github.com/${CHARTS_REPO}.git" "$WORKSPACE_DIR"
cd "$WORKSPACE_DIR"
# Configure git
git config user.name "GitHub Actions Bot"
git config user.email "actions@github.com"
# Checkout the main-mvp branch
echo "Checking out $CHARTS_BRANCH branch..."
git checkout "$CHARTS_BRANCH"
git pull origin "$CHARTS_BRANCH"
# Create a new branch for the PR
PR_BRANCH="update-find-mvp-${IMAGE_SHA:0:8}"
echo ":herb: Creating PR branch: $PR_BRANCH"
git checkout -b "$PR_BRANCH"
# Find and update the values file
VALUES_FILE="charts/datagovuk/values.yaml"
if [ ! -f "$VALUES_FILE" ]; then
  echo "Warning: $VALUES_FILE not found, searching for alternative locations..."
  # Try alternative locations
  if [ -f "charts/datagovuk/find/values.yaml" ]; then
    VALUES_FILE="charts/datagovuk/find/values.yaml"
  elif [ -f "values.yaml" ]; then
    VALUES_FILE="values.yaml"
  else
    echo "Error: Could not find values.yaml file"
    exit 1
  fi
fi
echo "Updating image SHA in $VALUES_FILE"
# Update the image tag/SHA for the Find application
# This uses sed to find and replace the image tag
# Adjust the pattern based on your actual values.yaml
if grep -q "find:" "$VALUES_FILE"; then
  # Update the tag under the find section
  sed -i.bak "s/\(find:.*tag:\s*\).*/\1${IMAGE_SHA}/" "$VALUES_FILE" || \
  sed -i.bak "/find:/,/tag:/ s/\(tag:\s*\).*/\1${IMAGE_SHA}/" "$VALUES_FILE"
else
  echo "Warning: Could not find 'find:' section in values file"
  # Fallback: try to update any 'tag:' field
  sed -i.bak "s/\(tag:\s*\).*/\1${IMAGE_SHA}/" "$VALUES_FILE"
fi
# Remove backup file
rm -f "${VALUES_FILE}.bak"
# Check if there are changes
if git diff --quiet; then
  echo "No changes detected. The image SHA may already be up to date."
  exit 0
fi
echo "Changes made:"
git diff "$VALUES_FILE"
COMMIT_MSG="Update Find image to ${IMAGE_SHA:0:8} for MVP
Automated update from datagovuk_find main-mvp branch
Commit: ${IMAGE_SHA}
Branch: ${GH_REF}
Environment: Integration
DGUK-156"
echo "Committing changes..."
git add "$VALUES_FILE"
git commit -m "$COMMIT_MSG"
echo "Pushing branch to remote..."
git push origin "$PR_BRANCH"
echo "Creating pull request..."
PR_TITLE="[MVP] Update Find image to ${IMAGE_SHA:0:8}"
PR_BODY="## Automated Update for main-mvp Branch
This updates the Find application image for the MVP branch.
**Details:**
- **Commit SHA:** \`${IMAGE_SHA}\`
- **Short SHA:** \`${IMAGE_SHA:0:8}\`
- **Source Branch:** \`${GH_REF}\`
- **Target Environment:** Integration
**Changes:**
- Updated Find image tag in \`${VALUES_FILE}\`
**Deployment:**
This will deploy to the Integration environment once merged and synced by ArgoCD.
---
*Automated by GitHub Actions*"
gh pr create \
  --repo "$CHARTS_REPO" \
  --base "$CHARTS_BRANCH" \
  --head "$PR_BRANCH" \
  --title "$PR_TITLE" \
  --body "$PR_BODY"
PR_URL=$(gh pr view "$PR_BRANCH" --repo "$CHARTS_REPO" --json url --jq .url)
echo "Pull request created successfully!"
echo "PR URL: $PR_URL"
cd /
rm -rf "$WORKSPACE_DIR"
echo "Script completed successfully!"
