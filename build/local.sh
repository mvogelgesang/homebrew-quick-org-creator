#!/bin/bash

set -e  # Exit on any error

local_tarball="tmp-quick-org-creator.tar.gz"
install_dir="$(brew --prefix)/opt/quick-org-creator/libexec"
backup_dir="$(brew --prefix)/opt/quick-org-creator/libexec-backup"

echo "Creating local build for testing..."

# Clean up any existing installation
echo "Removing existing installation..."
brew uninstall --force quick-org-creator 2>/dev/null || true

# Create backup of existing installation if it exists
if [ -d "$install_dir" ]; then
    echo "Backing up existing installation..."
    rm -rf "$backup_dir" 2>/dev/null || true
    cp -r "$install_dir" "$backup_dir" 2>/dev/null || true
fi

# Create the tarball for reference
echo "Creating tarball..."
tar -czvf $local_tarball src/ Formula ..scratchDefs fileTemplates VERSION > /dev/null

# Install files directly to the target location
echo "Installing local build directly..."
target_dir="$(brew --prefix)/opt/quick-org-creator/libexec"
mkdir -p "$target_dir"

# Copy all necessary files
cp -r src/* "$target_dir/"
cp -r ..scratchDefs "$target_dir/"
cp -r fileTemplates "$target_dir/"
cp VERSION "$target_dir/"

# Create symlink for the binary
bin_dir="$(brew --prefix)/bin"
mkdir -p "$bin_dir"
rm -f "$bin_dir/oc"
ln -sf "$target_dir/run.sh" "$bin_dir/oc"

# Make sure the main script is executable
chmod +x "$target_dir/run.sh"
chmod +x "$bin_dir/oc"

echo "Testing installation..."
oc --version

echo "✅ Local build installed successfully!"
echo ""
echo "Your local changes are now active. Test with: oc"
echo ""
echo "To restore production version, run: ./build/restoreProd.sh"