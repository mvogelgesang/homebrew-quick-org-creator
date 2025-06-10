#!/bin/bash

source ${oc_installedDir}/functions.sh

# Initialize arrays for remote names and host URLs
remote_names=()
remote_urls=()

# Function to retrieve value of oc_defaultRemote, if it does not exist, return empty string, otherwise return
get_defaultRemote() {
  if [ -z "${oc_defaultRemote}" ]; then
    update_or_add_var "oc_defaultRemote" "${oc_configFileName}" ""
    source "${oc_configFileName}"
  fi
}

# Function to display existing remotes
display_remotes() {
  get_defaultRemote
  if [ ${#oc_remoteNames[@]} -eq 0 ]; then
    _message "No existing remotes."
  else
    _message "Existing Remotes: (${oc_COLOR_NOTIFICATION}**${oc_COLOR_NOCOLOR} default)"
    for i in "${!oc_remoteNames[@]}"; do
      default=""
      if [ "${oc_defaultRemote}" == "${oc_remoteNames[$i]}" ]; then
        default="**"
      fi
      _message "- ${oc_remoteNames[$i]}${oc_COLOR_NOTIFICATION}${default}${oc_COLOR_NOCOLOR}: ${oc_remoteUrls[$i]}"
    done
    remote_names=("${oc_remoteNames[@]}")
    remote_urls=("${oc_remoteUrls[@]}")
  fi
}

# Function to add a new remote
add_remote() {
  remote_index=true
  _message "Enter remote name (leave blank to skip):"
  read remote_name
  if [ -n "$remote_name" ]; then
    # Check if the remote name already exists
    for i in "${!remote_names[@]}"; do
      if [ "${remote_names[$i]}" == "$remote_name" ]; then
        remote_index=false
        _message "Remote name already exists. Updating URL."
        _message "Enter new GitHub host URL:"
        read remote_url
        remote_urls[$i]="$remote_url"
        _message "success" "Remote updated: $remote_name -> $remote_url"
        return
      fi
    done
    if [ "${remote_index}" ]; then
      _message "Enter GitHub host URL (leave blank to skip):"
      read remote_url
      remote_names+=("$remote_name")
      remote_urls+=("$remote_url")
    fi
    _message "success" "Remote added: $remote_name -> $remote_url"
  else
    _message "No name provided. Skipping."
  fi
}

# Display existing remotes
display_remotes

# Prompt to add new remotes
while true; do
  _message "question" "Would you like to add a new remote? (y/n)"
  read add_remote_choice
  if [[ $add_remote_choice =~ ^[Yy]$ ]]; then
    add_remote
  else
    break
  fi
done

# Save the updated remotes array to a config file if needed
update_or_add_var "oc_remoteNames" "${oc_configFileName}" "${remote_names[@]}"
update_or_add_var "oc_remoteUrls" "${oc_configFileName}" "${remote_urls[@]}"
source "${oc_configFileName}"

defaultRemote=""
if [ -n "${oc_remoteNames[*]}" ]; then
  _message "question" "Pick a default remote from the list of GitHub remotes:"
  select remote in "${oc_remoteNames[@]}"; do
    if [ $REPLY == "0" ]; then
      break;
    elif [[ -n $remote ]]; then
      defaultRemote=$remote
      break;
    else
      _message "warn" "Invalid selection, try again$" >&2
    fi
  done
fi
update_or_add_var "oc_defaultRemote" "${oc_configFileName}" "$defaultRemote"
source "${oc_configFileName}"
_message ""
# Display final list of remotes
display_remotes

