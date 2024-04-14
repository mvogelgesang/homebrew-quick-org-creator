#!/bin/bash

results=($(sf data query -q "SELECT Id, Name, NamespacePrefix, NamespaceOrg FROM NamespaceRegistry" -o $oc_devHub --json | jq '.result.records[] | .NamespacePrefix'))

# Convert the array to a space-separated string
results_string=$(IFS=" "; echo "${results[*]}")

# Check if the variable exists in the .config file
if grep -q "oc_namespaceArray" ${oc_installedDir}/../.config; then
  # If it exists, replace it
  sed -i "" "s/oc_namespaceArray=.*/oc_namespaceArray=($results_string)/" ${oc_installedDir}/../.config
else
  # If it doesn't exist, add it
  echo "\nexport oc_namespaceArray=(${results[@]})" >> ${oc_installedDir}/../.config
fi

echo "List of namespaces updated successfully"
# Print the entries of the array
for entry in "${results[@]}"; do
  entry=${entry//\"/}
  echo "  -$entry"
done