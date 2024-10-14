#!/bin/bash

source ${oc_installedDir}/functions.sh

# Initialize arrays for remote names and host URLs
remote_names=()
remote_urls=()

# Function to display existing remotes
display_remotes() {
  if [ ${#oc_remoteNames[@]} -eq 0 ]; then
    echo "No existing remotes."
  else
    echo "Existing Remotes:"
    for i in "${!oc_remoteNames[@]}"; do

      echo "- ${oc_remoteNames[$i]}: ${oc_remoteUrls[$i]}"
    done
      remote_names=("${oc_remoteNames[@]}")
      remote_urls=("${oc_remoteUrls[@]}")
  fi
}

# Function to add a new remote
add_remote() {
  remote_index=true
  echo -e "Enter remote name (leave blank to skip):"
  read remote_name
  if [ -n "$remote_name" ]; then
    # Check if the remote name already exists
    for i in "${!remote_names[@]}"; do
      if [ "${remote_names[$i]}" == "$remote_name" ]; then
        remote_index=false
        echo -e "Remote name already exists. Updating URL."
        echo -e "Enter new GitHub host URL:"
        read remote_url
        remote_urls[$i]="$remote_url"
        echo -e "Remote updated: $remote_name -> $remote_url"
        return
      fi
    done
    if ["${remote_index}"]; then
      echo -e "Enter GitHub host URL (leave blank to skip):"
      read remote_url
      remote_names+=("$remote_name")
      remote_urls+=("$remote_url")
    fi
    echo -e "Remote added: $remote_name -> $remote_url"
  else
    echo -e "No name provided. Skipping."
  fi
}

# Display existing remotes
display_remotes

# Prompt to add new remotes
while true; do
  echo -e "Would you like to add a new remote? (y/n)"
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

# Display final list of remotes
display_remotes

# Example: echo "oc_remotesArray=(${oc_remotesArray[@]})" >> ${oc_installedDir}/../.config