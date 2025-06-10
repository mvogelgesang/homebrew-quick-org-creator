#!/bin/bash

## Script variables, update as necessary ##
export oc_alias=""
export oc_datedAlias=$(date '+%Y%m%d')_
export oc_update="N"
export oc_installedDir="$(brew --prefix quick-org-creator)/libexec"
export oc_configFilePath="$HOME/.quick-org-creator/"
export oc_configFileName="${oc_configFilePath}.config"
export oc_github=false
export oc_currentWorkingDirectory=$(pwd)

source ${oc_installedDir}/functions.sh

version=$(cat ${oc_installedDir}/VERSION)

_message "theme" "$oc_TITLE"                          

source "${oc_installedDir}/dependencies.sh"

if [ $? -eq 1 ]
then
  exit 1
fi

if test -f "${oc_configFileName}"; then
  source "${oc_configFileName}"
  else
  echo -e "${oc_COLOR_WARN}It looks like a config file is not setup, let's create one...${oc_COLOR_NOCOLOR}"
  source "${oc_installedDir}/config.sh"
  source "${oc_configFileName}"
fi

# Check for updates
if brew outdated | grep -q '^quick-org-creator '; then
  echo "An update for mvogelgesang/quick-org-creator is available. You can update it with 'brew upgrade mvogelgesang/quick-org-creator'."
fi

arg=$1
arg=$(echo $arg | tr '[:upper:]' '[:lower:]')

case $arg in
  "namespace")
    echo "Updating namespace list"
    echo ""
    source "${oc_installedDir}/namespace.sh"
    ;;
  "config")
    echo "Opening config editor"
    echo ""
    source "${oc_installedDir}/config.sh"
    ;;
  "devhub")
    echo "Updating DevHub list"
    echo ""
    source "${oc_installedDir}/devHub.sh"
    ;;
  "remote")
    echo "Configuring Remotes"
    echo ""
    source "${oc_installedDir}/remotes.sh"
    ;;
  "--version")
    echo $version
    ;;
  "help")
    echo "Quick Org Creator Commands"
    echo ""
    echo "config        - Runs configuration update and lets you set default params"
    echo "devhub        - Refreshes the list of authenticated DevHub orgs"
    echo "help          - Prints all commands"
    echo "namespace     - Refreshes the list of namespaces assocated with a given DevHub"
    echo "remote        - Configure the list of remotes used."
    echo "-o            - Creates only the scratch org, does not create repo or project directory"
    echo "--version     - Prints the current version of Quick Org Creator"
    ;;
  *)
    source "${oc_installedDir}/create.sh"
    ;;
esac


