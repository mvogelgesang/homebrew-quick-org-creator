#!/bin/bash

local_tarball="tmp-quick-org-creator.tar.gz"
formula="Formula/quick-org-creator.rb"
backup_formula="Formula/backup-quick-org-creator.rb"
tarball_path="$(pwd)/$local_tarball"
rm -rf $backup_formula

brew uninstall --force quick-org-creator
tar -czvf $local_tarball src/ Formula ..scratchDefs fileTemplates VERSION
hash_value=$(shasum -a 256 $local_tarball | awk '{print $1}')
cp $formula $backup_formula
sed -i '' "s|url \"https://.*|url \"file://localhost$tarball_path\"|" $formula
sed -i '' "s|sha256 \".*|sha256 \"$hash_value\"|" $formula
brew cleanup -s quick-org-creator
brew install --build-from-source $formula

cp $backup_formula $formula
rm -rf $backup_formula

oc --version