#!/bin/bash
set -e
# DGUK-156: Script to update Find SHA in govuk-dgu-charts main-mvp branch
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
echo ":clipboard: Configuration:"
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
# Find and update the values file
VALUES_FILE="charts/datagovuk/values.yaml"
if [ ! -f "$VALUES_FILE" ]; then
  echo "Warning: $VALUES_FILE not found, searching for alternative locations..."
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
if grep -q "find:" "$VALUES_FILE"; then
  sed -i.bak "s/\(find:.*tag:\s*\).*/\1${IMAGE_SHA}/" "$VALUES_FILE" || \
  sed -i.bak "/find:/,/tag:/ s/\(tag:\s*\).*/\1${IMAGE_SHA}/" "$VALUES_FILE"
else
  echo "Warning: Could not find 'find:' section in values file"
  sed -i.bak "s/\(tag:\s*\).*/\1${IMAGE_SHA}/" "$VALUES_FILE"
fi
# Remove backup file
rm -f "${VALUES_FILE}.bak"
# Check if there are changes
if git diff --quiet; then
  echo "No changes detected. The image SHA may already be up to date."
  exit 0
fi
# Show the changes
echo "Changes made:"
git diff "$VALUES_FILE"
# Commit the changes
COMMIT_MSG="Update Find image to ${IMAGE_SHA:0:8} for MVP
Automated update from datagovuk_find main-mvp branch
Commit: ${IMAGE_SHA}
Branch: ${GH_REF}
Environment: Integration
DGUK-156"
echo "Committing changes..."
git add "$VALUES_FILE"
git commit -m "$COMMIT_MSG"
# Push directly to main-mvp branch
echo "Pushing changes directly to $CHARTS_BRANCH..."
git push origin "$CHARTS_BRANCH"
echo "Successfully updated Find SHA in $CHARTS_BRANCH branch"
echo "ArgoCD will detect this change and deploy to Integration"
# Clean up
cd /
rm -rf "$WORKSPACE_DIR"
echo "Script completed successfully!"
