#!/bin/bash
source ${oc_installedDir}/functions.sh

results=($(sf data query -q "SELECT Id, Name, NamespacePrefix, NamespaceOrg FROM NamespaceRegistry" -o $oc_devHub --json | jq '.result.records[] | .NamespacePrefix'))

# Convert the array to a space-separated string
results_string=$(IFS=" "; echo "${results[*]}")

update_or_add_var "oc_namespaceArray" "${oc_configFileName}" "${results[@]}"

echo "List of namespaces updated successfully"
# Print the entries of the array
for entry in "${results[@]}"; do
  entry=${entry//\"/}
  echo "  -$entry"
done