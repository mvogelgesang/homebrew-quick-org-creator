# Quick Org Creator

A slim bash script to manage the repeated creation of scratch orgs for day to day work.

## Installation

`brew tap mvogelgesang/quick-org-creator`

`brew install quick-org-creator`

- Run from anywhere in your terminal with `oc`
- Running for the first time will create a config file to hold defaults for devhub org, parent folder, and scratch org definitions.

## Updating

`brew update`

`brew upgrade quick-org-creator`

## Outputs

- New Salesforce scratch org from desired devHub with specified org definition
- New project directory with org set as default target
- Initialized Git repo and creation of private GitHub repo

## Backlog

- A cleanup script to clear out old `node_modules` folders
- If a config value is missing, prompt for it
- Org picker based on authenticated dev hub orgs
- Directory picker based on folders available from run location

## Delivered Features

✔️ [Issue 3](https://github.com/mvogelgesang/quick-org-creator/issues/3) - Check for repo updates 
✔️ Include a readme file in each directory containing more details about the scratch org, why it was created, etc

## Local Testing

`brew uninstall quick-org-creator`
`tar -czvf tmp-quick-org-creator.tar.gz src/ Formula ..scratchDefs fileTemplates`
`shasum -a 256 tmp-quick-org-creator.tar.gz`
update url and sha in Formula
`brew install --build-from-source Formula/quick-org-creator.rb`

## Deploying

Assumes all changes to scripts and templates are committed and merged into main.

`git tag -a v{versionNumber} -m {versionNumber}`

`git push origin v{versionNumber}`

- In GitHub, create new release from tag.
- Copy link to tarball
- Fetch SHA-256 using tarball url

`curl -L {tarballUrl} | shasum -a 256`

- Update `./Formula/quick-org-creator.rb` and replace url and sha contents.
- Commit all changes and push to main
