#!/bin/bash
source ${oc_installedDir}/functions.sh

results=($(sf org list --json | jq '.result.devHubs[] | .alias'))

# Convert the array to a space-separated string
results_string=$(IFS=" "; echo "${results[*]}")

update_or_add_var "oc_devHubArray" "${oc_installedDir}/../.config" "${results[@]}"
