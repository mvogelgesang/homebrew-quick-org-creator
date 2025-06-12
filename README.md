# Quick Org Creator

A homebrew package to manage the repeated creation of scratch orgs for day to day work.

- [Quick Org Creator](#quick-org-creator)
  - [Installation](#installation)
  - [Dependencies](#dependencies)
  - [Running](#running)
    - [Create a new scratch org](#create-a-new-scratch-org)
    - [Refresh config and defaults](#refresh-config-and-defaults)
    - [Refresh list of DevHub orgs](#refresh-list-of-devhub-orgs)
    - [Refresh namespace list](#refresh-namespace-list)
    - [Print commands](#print-commands)
    - [Create Org Only](#create-org-only)
    - [Check version](#check-version)
  - [Updating](#updating)
  - [Outputs](#outputs)
  - [Backlog](#backlog)
  - [Delivered Features](#delivered-features)
  - [Local Testing](#local-testing)
    - [Restoring Production Version Locally](#restoring-production-version-locally)
  - [Deploying](#deploying)
    - [Scripted Instructions](#scripted-instructions)
    - [Legacy Instructions](#legacy-instructions)

## Installation

`brew tap mvogelgesang/quick-org-creator`

`brew install quick-org-creator`

## Dependencies

- [Salesforce CLI](https://developer.salesforce.com/tools/salesforcecli)
- [Git](https://git-scm.com/)
- [GitHub CLI (Optional)](https://cli.github.com/)

## Running

The first time `oc` is run, it will establish a configuration file that is used to supply the list of DevHub orgs, any namespaces, and set default values.

### Create a new scratch org

`oc`

Creates a new scratch org and prompts user to identify which DevHub to use, folder location, and scratch definition file. Upon completion, the following are produced

- New Salesforce scratch org from desired DevHub with specified org definition
- New project directory with org set as default target
- Initialized Git repo and creation of corresponding private GitHub repo (if GitHub CLI is installed)

### Refresh config and defaults

`oc config`

Allows you to set default values for:

- DevHub
- Project folder location
- Default scratch org duration
- Scratch Definition File
- Default scratch definition features/ settings that always get applied
- Manage multiple Git remotes and set default

### Refresh list of DevHub orgs

`oc devhub`

Saves a local list of DevHub orgs that have been authenticated via the CLI. If a devhub does not have an alias, it appears as blank in the list.

### Refresh namespace list

`oc namespace`

Refreshes the list of namespaces associated with your default DevHub org.

### Print commands

`oc help`

Prints all commands and brief descriptions of each.

### Create Org Only

`oc -o`

Creates an org but skips steps to create associated project directory or github repo.

### Check version

`oc --version`

Prints the current version of Quick Org Creator.

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

- ✔️ [Issue 52](https://github.com/mvogelgesang/quick-org-creator/issues/52) - Create and manage common settings/ features to apply to all scratch orgs.
- ✔️ [Issue 48](https://github.com/mvogelgesang/quick-org-creator/issues/48) - Create only the org, no project directory
- ✔️ [Issue 3](https://github.com/mvogelgesang/quick-org-creator/issues/3) - Check for repo updates
- ✔️ Include a readme file in each directory containing more details about the scratch org, why it was created, etc

## Local Testing

`./build/local.sh` Uninstalls any existing version of `oc`, builds from local directory and installs from locally produced bundle `tmp-quick-org-creator.tar.gz`. Once built, can be run using `oc` alias.

### Restoring Production Version Locally

`./build/restoreProd.sh`

Removes locally built version of package and installs from tap.

## Deploying

### Scripted Instructions

*Note* - scripted instructions change the tag naming pattern and remove the leading "v" from tag names.

`./build/publish-release.sh`

### Legacy Instructions

Assumes all changes to scripts and templates are committed and merged into main.

`versionNumber=#.#.#`

`git pull origin develop`

`git merge main` >> this should say that it is already up to date. If not, merge.

`git checkout main`

`git merge develop`

`git push origin main`

`echo -n $versionNumber>VERSION`

`git add VERSION`

`git commit -m ${versionNumber}`

`git tag -a v${versionNumber} -m ${versionNumber}`

`git push origin v${versionNumber}`

- In GitHub, create new release from tag.
- Copy link to tarball
- Fetch SHA-256 using tarball url

`curl -L {tarballUrl} | shasum -a 256`

- Update `./Formula/quick-org-creator.rb` and replace url and sha contents.
- Commit all changes and push to main

`unset versionNumber`

`git push origin main`

`git checkout develop`

`git merge main`

`git push origin develop`

- Now `main` and `develop` will be at the same commit hash.
