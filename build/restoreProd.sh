#!/bin/bash

set -e  # Exit on any error

echo "Restoring production version of Quick Org Creator..."

# Clean up any direct installation
install_dir="$(brew --prefix)/opt/quick-org-creator/libexec"
backup_dir="$(brew --prefix)/opt/quick-org-creator/libexec-backup"
bin_dir="$(brew --prefix)/bin"

echo "Cleaning up local installation..."
rm -f "$bin_dir/oc"
rm -rf "$(brew --prefix)/opt/quick-org-creator"

# Restore backup if it exists
if [ -d "$backup_dir" ]; then
    echo "Restoring previous installation..."
    cp -r "$backup_dir" "$install_dir"
    rm -rf "$backup_dir"
fi

# Uninstall any brew version
echo "Removing any existing brew installation..."
brew uninstall --force quick-org-creator 2>/dev/null || true

# Install production version
echo "Installing production version..."
brew tap mvogelgesang/quick-org-creator
brew install quick-org-creator

echo "Testing installation..."
oc --version

echo "✅ Production version restored successfully!"