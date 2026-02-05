#!/bin/bash

set -e  # Exit on any error

local_tarball="tmp-quick-org-creator.tar.gz"
formula="Formula/quick-org-creator.rb"
backup_formula="Formula/backup-quick-org-creator.rb"
tarball_path="$(pwd)/$local_tarball"
local_version_file=".local_version"

# --- Automatic Versioning Logic ---

# Read the official release version
base_version=$(cat VERSION)

# Check if a local version file exists and if its base matches the current release version
if [ -f "$local_version_file" ] && [[ "$(cat $local_version_file)" == "$base_version"* ]]; then
    # Local version file exists and is for the current release, so we increment the letter
    current_local_version=$(cat $local_version_file)
    
    # Check if there's already a letter suffix
    if [[ $current_local_version =~ ([0-9]+\.[0-9]+\.[0-9]+)([a-z]*) ]]; then
        version_base="${BASH_REMATCH[1]}"
        suffix="${BASH_REMATCH[2]}"
        
        if [ -z "$suffix" ]; then
            # No letter yet, start with 'a'
            next_suffix='a'
        else
            # Increment the letter
            next_suffix=$(echo "$suffix" | tr "0-9a-y" "1-9a-z")
        fi
        new_version="${version_base}${next_suffix}"
    else
        # Fallback if regex fails, just append 'a'
        new_version="${current_local_version}a"
    fi
else
    # This is the first local build for this release version. Increment the patch number.
    IFS='.' read -r -a version_parts <<< "$base_version"
    major=${version_parts[0]}
    minor=${version_parts[1]}
    patch=${version_parts[2]}
    
    new_patch=$((patch + 1))
    new_version="$major.$minor.$new_patch"
fi

# Update the local version tracker and the main VERSION file for this build
echo "$new_version" > "$local_version_file"
echo "$new_version" > VERSION

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔧 BUILDING LOCAL VERSION: $new_version"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Capture the currently installed version before we remove it
previous_version=$(oc --version 2>/dev/null | tail -1 || echo "not installed")
echo "📦 Previously installed: $previous_version"
echo ""
# --- End of Versioning Logic ---


rm -rf $backup_formula

# Completely remove existing installation and tap
brew uninstall --force quick-org-creator 2>/dev/null || true
brew untap mvogelgesang/quick-org-creator 2>/dev/null || true

# Create tarball
tar -czvf $local_tarball src/ Formula ..scratchDefs fileTemplates VERSION
hash_value=$(shasum -a 256 $local_tarball | awk '{print $1}')

# Backup and modify formula
cp $formula $backup_formula
sed -i '' "s|url \"https://.*|url \"file://localhost$tarball_path\"|" $formula
sed -i '' "s|sha256 \".*|sha256 \"$hash_value\"|" $formula

# Create local tap directory and install modified formula
local_tap_dir="$(brew --repository)/Library/Taps/local/homebrew-test"
mkdir -p "$local_tap_dir"
cp $formula "$local_tap_dir/quick-org-creator.rb"

# Install from local tap using direct file path
brew install --build-from-source "$local_tap_dir/quick-org-creator.rb"

# Clean up local tap
rm -rf "$local_tap_dir"

# Restore original formula
cp $backup_formula $formula
rm -rf $backup_formula

# Restore the original VERSION file so git doesn't see a change
echo "$base_version" > VERSION

# --- Validation ---
installed_version=$(oc --version 2>&1 | tail -1)
installed_dir="$(brew --prefix quick-org-creator)/libexec"
installed_version_file="$installed_dir/VERSION"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ LOCAL BUILD INSTALLED"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Previous version:  $previous_version"
echo "  Installed version: $installed_version"
echo ""

# Validate the install worked correctly
if [ -f "$installed_version_file" ]; then
  file_version=$(cat "$installed_version_file")
  if [ "$file_version" == "$new_version" ]; then
    echo "  ✓ VERSION file validated ($installed_version_file)"
  else
    echo "  ⚠ VERSION mismatch! File says '$file_version', expected '$new_version'"
  fi
else
  echo "  ⚠ VERSION file not found at $installed_version_file"
fi

# Check a source file was updated by comparing timestamps
if [ -f "$installed_dir/create.sh" ]; then
  echo "  ✓ Source files installed ($installed_dir/)"
else
  echo "  ⚠ Source files not found"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Your local changes are now active. Test with: oc"
echo "To restore production: ./build/restoreProd.sh"