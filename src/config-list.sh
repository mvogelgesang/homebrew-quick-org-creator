#!/bin/bash

# Define the path to your config file
CONFIG_FILE="$oc_configFileName"

# Check if the config file exists and source it.
# 'source' loads the variables into the current script's environment.
if [[ -f "$CONFIG_FILE" ]]; then
  source "$CONFIG_FILE"
else
  echo "Error: Config file not found at '$CONFIG_FILE'"
  exit 1
fi

_message "--- Current OC Configuration ---"

# Use printf for clean, aligned columns.
# The "%-28s" format pads the label to 28 characters.
printf "%-28s: %s\n" "Default Dev Hub" "$oc_devHub"
printf "%-28s: %s\n" "Default Project Folder" "$oc_folder"
printf "%-28s: %s\n" "Default Scratch Definition" "$oc_scratchDef"
printf "%-28s: %s\n" "Default Scratch Duration" "$oc_duration"
printf "%-28s: %s\n" "Default Git Remote" "$oc_defaultRemote"
printf "%-28s: %s\n" "Preferred IDE" "${oc_preferredIDE:-vscode}"
_message ""
# For arrays, it's best to loop through and print each element.
print_array "Authenticated DevHubs" "${oc_devHubArray[@]}"
_message ""
print_array "Namespaces Registered to $oc_devHub" "${oc_namespaceArray[@]}"
_message ""

print_arrays_parallel "Git Remotes" "Remote Name" oc_remoteNames "Remote URL (if not github.com)" oc_remoteUrls

