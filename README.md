# Quick Org Creator

A slim bash script to manage the repeated creation of scratch orgs for day to day work.

## Setup

- Clone into folder where you manage your development projects. Mine is called `~/Develop`
- Open `create.sh` in your editor and update `devHub` and `folder` variables to your desired defaults
- Run it from your development project folder `./utilities/create.sh`

New org will be created, browser will open to org, VSCode will open new window.

## Backlog

- Include a readme file in each directory containing more details about the scratch org, why it was created, etc
- A cleanup script to clear out old `node_modules` folders
- Org picker based on authenticated dev hub orgs
- Directory picker based on folders available from run location
