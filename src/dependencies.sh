#!/bin/bash
missingDependency=false

_message "Checking dependencies..."

if ! command -v sf &> /dev/null
then
    _message "error" "Salesforce CLI could not be found. You must install this first.\n"
    _message "npm i -g @salesforce/cli\n"
    _message "Exiting..."
    missingDependency=true
fi

if ! command -v gh &> /dev/null
  then
    _message "warn" "GitHub CLI could not be found, GitHub steps will be skipped."
    missingDependency=true
  else
    export oc_github=true
fi

if ! command -v jq &> /dev/null
  then
    _message "warn" "jq could not be found. Install with homebrew.\n\n"
    _message "  brew install jq\n\n"
    missingDependency=true
fi

if [ "$missingDependency" = true ]
  then
    _message "error" "One or more dependencies could not be found. Please ensure you have installed all necessary dependencies.\n\n"
    _message "Exiting..."
    exit 1
  else
    _message "success" "Done.\n"
fi

# check if code is a valid command in the terminal, if not, direct user to help resources
if ! command -v code &> /dev/null
then
  _message "warn" ">> VSCode `code` terminal command not found, you will have to launch your editor manually."
  _message ">> To add `code` as a terminal command, open VSCode, press CMD+Shift+P, select Install 'code' command in PATH"
  _message ">> If that does not work, see https://github.com/microsoft/vscode/issues/154163"
fi