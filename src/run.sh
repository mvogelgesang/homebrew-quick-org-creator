#!/bin/bash

## Script variables, update as necessary ##
export oc_alias=""
export oc_datedAlias=$(date '+%Y%m%d')_
export oc_update="N"
export oc_installedDir="$(brew --prefix quick-org-creator)/libexec"
export oc_configFilePath="$HOME/.quick-org-creator/"
export oc_configFileName="${oc_configFilePath}.config"
export oc_defaultScratchDefFile="${oc_configFilePath}defaultScratchDef.json"
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
  _message "warning" "It looks like a config file is not setup, let's create one..."
  source "${oc_installedDir}/config.sh"
  source "${oc_configFileName}"
fi

# Load upgrade system and handle version migrations
source "${oc_installedDir}/upgrade.sh"
main_upgrade_check

# Check for updates
if brew outdated | grep -q '^quick-org-creator '; then
  _message "An update for mvogelgesang/quick-org-creator is available. You can update it with 'brew upgrade mvogelgesang/quick-org-creator'."
fi

if [[ "$1" == "--version" ]]; then
  _message "theme" $version
  exit 0 # Exit after printing version
fi

# The main action is the first argument
action="$1"
action=$(echo "$action" | tr '[:upper:]' '[:lower:]')

# After getting the action, shift the arguments.
# This makes the sub-action (if any) become the new $1.
shift

case $action in
  "namespace")
    _message "Updating namespace list...\n"
    source "${oc_installedDir}/namespace.sh"
    ;;

  "config")
    # At this point, "config" has been processed and shifted away.
    # The new $1 is either "list", another sub-action, or empty.
    sub_action="$1"
    sub_action=$(echo "$sub_action" | tr '[:upper:]' '[:lower:]')

    case $sub_action in
      "list")
        _message "Listing current configuration...\n"
        source "${oc_installedDir}/config-list.sh"
        ;;
      "")
        # Handles the case where the user just typed "oc config"
        _message "Opening config editor...\n"
        source "${oc_installedDir}/config.sh"
        ;;
      *)
        _message "Error: Unknown subcommand '$sub_action' for config." >&2
        exit 1
        ;;
    esac
    ;;

  "devhub")
    _message "Updating DevHub list..."
    source "${oc_installedDir}/devHub.sh"
    ;;

  "remote")
    _message "Configuring Remotes..."
    source "${oc_installedDir}/remotes.sh"
    ;;

  "help")
    _message "Quick Org Creator Commands"
    _message "  config        - Runs configuration update and lets you set default params"
    _message "  config list   - Prints the contents of the config file"
    _message "  devhub        - Refreshes the list of authenticated DevHub orgs"
    _message "  help          - Prints all commands"
    _message "  namespace     - Refreshes the list of namespaces assocated with a given DevHub"
    _message "  remote        - Configure the list of remotes used."
    _message "  -o            - Creates only the scratch org, does not create repo or project directory"
    _message "  --version     - Prints the current version of Quick Org Creator"
    ;;
  *)
    # The default case runs create.sh. We pass any remaining arguments to it.
    # The original $1 (the action) was shifted, so "$@" contains any sub-args.
    source "${oc_installedDir}/create.sh" "$action" "$@"
    ;;
esac


