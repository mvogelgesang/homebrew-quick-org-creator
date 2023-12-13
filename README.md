# Quick Org Creator

A slim bash script to manage the repeated creation of scratch orgs for day to day work.

## Setup

- Clone into folder where you manage your development projects. Mine is called `~/Develop`
- Run it from your development project folder `./utilities/create.sh`
- Running for the first time will create a config file to hold defaults for devhub org, parent folder, and scratch org definitions.

## Outputs

- New Salesforce scratch org from desired devHub with specified org definition
- New project directory with org set as default target
- Initialized Git repo and creation of private GitHub repo

## Backlog

- Include a readme file in each directory containing more details about the scratch org, why it was created, etc
- A cleanup script to clear out old `node_modules` folders
- Org picker based on authenticated dev hub orgs
- Directory picker based on folders available from run location
