#!/bin/bash

## Script variables, update as necessary ##
alias=""
datedAlias=$(date '+%Y%m%d')_
installedDir="`dirname $0`"
if test -f "${installedDir}/.config"; then
  source "${installedDir}/.config"
  else
  echo -e "${cYellow}It looks like a config file is not setup, let's create one...${cNoColor}"
  sh "${installedDir}/config.sh"
  source "${installedDir}/.config"
fi

github=false
currentWorkingDirectory=$(pwd)

## Colors
cWhite='\033[0;37m'
cBlue='\033[0;34m' 
cCyan='\033[0;36m'
cLightCyan='\033[0;96m'
cLightBlue='\033[0;94m'
cGreen='\033[0;32m'
cYellow='\033[0;33m'
cMagenta='\033[0;35m'
cRed='\033[0;31m'
bBlue='\033[0;44m'
bCyan='\033[0;46m'
bLightBlue='\033[0;104m'
bLightCyan='\033[0;106m'
cNoColor='\033[0;0m'
arrow="  -> "

echo -e "${cMagenta}
===================================================
 __   __   __      __   __   ___      ___  __   __  
/  \ |__) / _\`    /  \` |__) |__   /\   |  /  \ |__) 
\__/ |  \ \__>    \__, |  \ |___ /~~\  |  \__/ |  \\
=================================================== 
${cNoColor}"                                                    

## Start script
echo "DevHub (leave blank for default $devHub)"
read o
if [ ! -z "$o" ]
  then
    devHub=$o
fi

echo "This script will create a new scratch org off of $devHub. Checking pre-conditions..."

if ! command -v sf &> /dev/null
then
    echo -e "${cRed}Salesforce CLI could not be found. You must install this first. Exiting...${cNoColor}"
    exit 1
fi

if ! command -v gh &> /dev/null
  then
    echo "${cRed}GitHub CLI could not be found, GitHub steps will be skipped.${cNoColor}"
    exit 1
  else
    github=true
fi

# check if code is a valid command in the terminal, if not, direct user to help resources
if ! command -v code &> /dev/null
then
  echo "${cRed}>> VSCode `code` terminal command not found, you will have to launch your editor manually.${cNoColor}"
  echo ">> To add `code` as a terminal command, open VSCode, press CMD+Shift+P, select Install 'code' command in PATH"
  echo ">> If that does not work, see https://github.com/microsoft/vscode/issues/154163"
fi

# read in name of project
echo ""
echo -e "${cCyan}What is the alias for the org? This might be a Org62 case number (37711301-pushUpgrades), trailhead exercise, etc.${cNoColor}"
read alias
datedAlias+=$alias

# user can override the scratch definition if desired
echo ""
echo -e "${cCyan}Scratch Definition (Enter 0 for default "$scratchDef")${cNoColor}"
  select file in "${installedDir}/..scratchDefs/"*.json; do
    if [ $REPLY == "0" ]; then
      echo Default chosen
      break;
    elif [[ -z $file ]]; then
      echo -e "${cYellow}Invalid selection, try again${cNoColor}" >&2
    else
      scratchDef=$file
      break;
    fi
done
echo Scratch definition set: $scratchDef

# default parent folder is set but can be overridden
echo ""
echo -e "${cCyan}What folder should this go in? (Leave blank for default $folder)${cNoColor}"
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

# write the readme
echo -e "${cCyan}Describe this goals for this project${cNoColor}"
read goals
echo "# ${alias}" > $folder/$datedAlias/README.md
echo "" >> $folder/$datedAlias/README.md
echo $goals >> $folder/$datedAlias/README.md

# open code editor
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

echo "Creating GitHub Action Workflow Rules"
mkdir -p .github/workflows
cp -a "$currentWorkingDirectory/utilities/fileTemplates/workflows/." .github/workflows/

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