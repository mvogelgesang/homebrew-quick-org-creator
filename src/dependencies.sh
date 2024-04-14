#!/bin/bash
missingDependency=false

echo "Checking dependencies..."

if ! command -v sf &> /dev/null
then
    echo -e "${oc_COLOR_ERROR}
    Salesforce CLI could not be found. You must install this first.${oc_COLOR_NOCOLOR}
    
    npm i -g @salesforce/cli

    Exiting..."
    missingDependency=true
fi

if ! command -v gh &> /dev/null
  then
    echo -e "${oc_COLOR_WARN}GitHub CLI could not be found, GitHub steps will be skipped.${oc_COLOR_NOCOLOR}"
    missingDependency=true
  else
    export oc_github=true
fi

if ! command -v jq &> /dev/null
  then
    echo -e "${oc_COLOR_WARN}jq could not be found. Install with homebrew.${oc_COLOR_NOCOLOR}\n\n  brew install jq\n\n"
    missingDependency=true
fi

if [ "$missingDependency" = true ]
  then
    echo -e "${oc_COLOR_ERROR}One or more dependencies could not be found. Please ensure you have installed all necessary dependencies.${oc_COLOR_NOCOLOR}\n\nExiting..."
    exit 1
fi

# check if code is a valid command in the terminal, if not, direct user to help resources
if ! command -v code &> /dev/null
then
  echo -e "${oc_COLOR_WARN}>> VSCode `code` terminal command not found, you will have to launch your editor manually.${oc_COLOR_NOCOLOR}"
  echo -e ">> To add `code` as a terminal command, open VSCode, press CMD+Shift+P, select Install 'code' command in PATH${oc_COLOR_NOCOLOR}"
  echo -e ">> If that does not work, see https://github.com/microsoft/vscode/issues/154163${oc_COLOR_NOCOLOR}"
fi