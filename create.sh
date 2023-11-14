#!/bin/bash

## Script variables, update as necessary ##
alias=""
datedAlias=$(date '+%Y%m%d')_
scratchDef="utilities/..scratchDefs/default.json"
devHub="pboDevHub"
folder="pboDevHub"
github=false

## Start script
echo "DevHub (leave blank for default $devHub)"
read o
if [ ! -z "$o" ]
  then
    devHub=$o
fi

echo "This script will create a new scratch org off of $devHub. Checking pre-conditions..."

if ! command -v sf
then
    echo "Salesforce CLI could not be found. You must install this first. Exiting..."
    exit 1
fi

if ! command -v gh
  then
    echo "GitHub CLI could not be found, GitHub steps will be skipped"
    exit 1
  else
    github=true
fi

# check if code is a valid command in the terminal, if not, direct user to help resources
if ! command -v code
then
  echo ">> VSCode `code` terminal command not found, you will have to launch your editor manually."
  echo ">> To add `code` as a terminal command, open VSCode, press CMD+Shift+P, select Install 'code' command in PATH"
  echo ">> If that does not work, see https://github.com/microsoft/vscode/issues/154163"
fi

# read in name of project
echo ""
echo "What is the alias for the org? This might be a Org62 case number (37711301-pushUpgrades), trailhead exercise, etc."
read alias
datedAlias+=$alias

# user can override the scratch definition if desired
echo "Scratch Definition (leave blank for default $scratchDef)"
read s
if [ ! -z "$s" ]
  then
    scratchDef=$s
fi

# default parent folder is set but can be overridden
echo "What folder should this go in? (Leave blank for default $folder)"
read f
if [ ! -z "$f" ]
  then
    folder=$f
fi

# echo "Devhub: $devHub"
# echo "scratchDef: $scratchDef"
# echo "alias: $alias"

# create the scratch org and project folder. 
# Once done, open folder in code and install dependencies
sf org create scratch -f $scratchDef -a $alias -v $devHub -w 10 -y 21
sf org resume scratch --use-most-recent
echo "Scratch org creation done"
echo "Setting target-org and generating project"
sf project generate -t standard -n $datedAlias -d $folder
code $folder/$datedAlias -g $folder/$datedAlias/README.md:2
cd $folder/$datedAlias
sf config set target-org=$alias
echo "Resetting the password"
sf org generate password --complexity 3
echo "Installing dependencies"
npm i

echo "Creating pre-commit hook for Code Analyzer"
echo -e "// lint-staged.config.js
module.exports = {
  \"**/*.cls\": (filenames) => \"sf scanner run -f table -s 3 -t \" + filenames.join(\", \") 
};
" > lint-staged.config.js

if $github
then
  echo "Creating a git repo locally and on GitHub"
  git init 
  gh repo create $datedAlias --private  -s .  --disable-wiki --disable-issues
else
  echo "Github CLI not setup, skipping Git-related steps"
fi

echo "Opening the new org"
sf org open -o $alias
echo "You will need to authenticate your new org"