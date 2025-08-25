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

# check if the configured IDE CLI is available
check_ide_available