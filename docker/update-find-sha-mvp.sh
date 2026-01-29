#!/bin/bash
set -e
# Script to update Find SHA in govuk-dgu-charts main-mvp branch
# This script directly updates the main-mvp branch - ArgoCD watches it and deploys to Integration
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
echo "   Configuration:"
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
# Path to the Find image configuration file
# Structure charts/datagovuk/images/integration/find.yaml
FIND_IMAGE_FILE="charts/datagovuk/images/integration/find.yaml"
if [ ! -f "$FIND_IMAGE_FILE" ]; then
  echo "Error: $FIND_IMAGE_FILE not found"
  echo "Expected path: charts/datagovuk/images/integration/find.yaml"
  exit 1
fi
echo "Updating image tag in $FIND_IMAGE_FILE"
# Show current content
echo "Current content:"
cat "$FIND_IMAGE_FILE"
# Update the tag field
sed -i.bak "s/^\(tag:\s*\).*/\1${IMAGE_SHA}/" "$FIND_IMAGE_FILE"
# Remove backup file
rm -f "${FIND_IMAGE_FILE}.bak"
# Check if there are changes
if git diff --quiet; then
  echo "No changes detected. The image SHA may already be up to date."
  exit 0
fi
# Show the changes
echo "Changes made:"
git diff "$FIND_IMAGE_FILE"
# Commit the changes
COMMIT_MSG=" Update Find image to ${IMAGE_SHA:0:8} for MVP
Commit: ${IMAGE_SHA}"
echo "Committing changes..."
git add "$FIND_IMAGE_FILE"
git commit -m "$COMMIT_MSG"
# Push directly to main-mvp branch
echo "Pushing changes directly to $CHARTS_BRANCH..."
git push origin "$CHARTS_BRANCH"
echo "Successfully updated Find SHA in $CHARTS_BRANCH branch"
echo "Updated file: $FIND_IMAGE_FILE"
echo "New SHA: $IMAGE_SHA"
echo "ArgoCD will detect this change and deploy to Integration"
# Clean up
cd /
rm -rf "$WORKSPACE_DIR"
echo "Script completed successfully!"
