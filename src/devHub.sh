#!/bin/bash
source ${oc_installedDir}/functions.sh

echo "Refreshing list of authenticated DevHubs..."
results=($(sf org list --json | jq '.result.devHubs[] | .alias'))

# Convert the array to a space-separated string
results_string=$(IFS=" "; echo "${results[*]}")

update_or_add_var "oc_devHubArray" "${oc_configFileName}" "${results[@]}"
echo -e "${oc_COLOR_SUCCESS}Done.${oc_COLOR_NOCOLOR}"
echo ""