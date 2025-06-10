#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- CONFIGURATION ---
# IMPORTANT: Update these variables for your project.
# Your GitHub repository in "owner/repo" format.
REPO="mvogelgesang/quick-org-creator" 
# The path to your Homebrew formula file.
FORMULA_FILE="./Formula/quick-org-creator.rb"
# The name of your primary development branch.
DEV_BRANCH="develop"
# The name of your main/production branch.
MAIN_BRANCH="main"

# --- PRE-FLIGHT CHECKS ---

# 1. Check for required tools
if ! command -v gh &> /dev/null; then
    echo "Error: GitHub CLI 'gh' is not installed. Please install it to continue."
    echo "See: https://cli.github.com/"
    exit 1
fi

# 2. Check for a version number argument
if [ -z "$1" ]; then
  echo "Error: No version number supplied."
  echo "Usage: ./publish-release.sh #.#.#"
  exit 1
fi

VERSION=$1
TAG="v${VERSION}"

# 3. Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo "Error: You have uncommitted changes. Please commit or stash them first."
    exit 1
fi

echo "Starting release process for version ${TAG}..."

# --- GIT FLOW: MERGE AND TAG ---

echo "Syncing branches..."
git checkout ${DEV_BRANCH}
git pull origin ${DEV_BRANCH}

git checkout ${MAIN_BRANCH}
git pull origin ${MAIN_BRANCH}
git merge --no-ff ${DEV_BRANCH} -m "Merge branch '${DEV_BRANCH}' for release ${TAG}"
git push origin ${MAIN_BRANCH}

echo "Updating VERSION file and tagging..."
echo -n "${VERSION}" > VERSION
git add VERSION
git commit -m "Bump version to ${VERSION}"
git tag -a "${TAG}" -m "Release ${VERSION}"
git push origin "${TAG}"

# --- AUTOMATED GITHUB RELEASE AND FORMULA UPDATE ---

echo "Creating GitHub release..."
# This creates the release and the source code assets (tar.gz, zip)
gh release create "${TAG}" --title "Release ${VERSION}" --generate-notes

echo "Fetching new release assets..."
# Construct the tarball URL automatically
TARBALL_URL="https://github.com/${REPO}/archive/refs/tags/${TAG}.tar.gz"

echo "Calculating SHA-256 for ${TARBALL_URL}..."
# Download the tarball and calculate the SHA-256 hash in one step
NEW_SHA=$(curl -sL "${TARBALL_URL}" | shasum -a 256 | awk '{print $1}')
echo "  New SHA-256: ${NEW_SHA}"

echo "Updating Homebrew formula at ${FORMULA_FILE}..."
# Use sed to replace the url and sha256 lines.
# The `''` after -i makes it compatible with both macOS and Linux sed.
sed -i'' -e "s|url \".*\"|url \"${TARBALL_URL}\"|" "${FORMULA_FILE}"
sed -i'' -e "s|sha256 \".*\"|sha256 \"${NEW_SHA}\"|" "${FORMULA_FILE}"
echo "  Formula updated."

# --- GIT FLOW: FINALIZE AND SYNC BACK ---

echo "Committing and pushing formula update..."
git add "${FORMULA_FILE}"
git commit -m "Update Homebrew formula for ${TAG}"
git push origin ${MAIN_BRANCH}

echo "Syncing changes back to ${DEV_BRANCH}..."
git checkout ${DEV_BRANCH}
git merge ${MAIN_BRANCH}
git push origin ${DEV_BRANCH}

echo ""
echo "✅ Done!"
echo "Version ${TAG} has been published successfully."
echo "Branches '${MAIN_BRANCH}' and '${DEV_BRANCH}' are now in sync."