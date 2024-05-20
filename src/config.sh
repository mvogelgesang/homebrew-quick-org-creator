#!/bin/bash
source ${oc_installedDir}/functions.sh

devhub=''
folderPath=''
scratchDef=''

mkdir -p $oc_configFilePath
touch $oc_configFileName

source ${oc_installedDir}/devHub.sh
source $oc_configFileName

echo ""
echo -e "${oc_COLOR_THEME}
------------------------------
=======CONFIG EDITOR==========
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
${oc_COLOR_NOCOLOR}"       

if [ -z "${oc_devHubArray[*]}" ]
then
  echo -e "${oc_COLOR_QUESTION}What alias should be used as your default dev hub org${oc_COLOR_NOCOLOR}"
  read alias
else
  echo -e "${oc_COLOR_QUESTION}Pick a default devHub from the list of authenticated devhubs:${oc_COLOR_NOCOLOR}"
  select dh in "${oc_devHubArray[@]}"; do
    if [ $REPLY == "0" ]; then
      alias=""
      break;
    elif [[ -n $dh ]]; then
      alias=$dh
      break;
    else
      echo -e "${oc_COLOR_WARN}Invalid selection, try again${oc_COLOR_NOCOLOR}" >&2
    fi
  done
fi
update_or_add_var "oc_devHub" "${oc_configFileName}" $alias

echo ""
echo -e "${oc_COLOR_QUESTION}What folder should projects be created in? (Enter full path ~/myfolder/path${oc_COLOR_NOCOLOR}"
read folderPath
folder=$folderPath
update_or_add_var "oc_folder" "${oc_configFileName}" $folder

echo ""
echo -e "${oc_COLOR_QUESTION}Would you like to set a default scratch org definition file?${oc_COLOR_NOCOLOR}"

scratchDefFiles=(${oc_installedDir}/..scratchDefs/*.json)
scratchDefFileNames=()
for file in "${scratchDefFiles[@]}"; do
  scratchDefFileNames+=("$(basename "$file")")
done

select fileName in "${scratchDefFileNames[@]}"; do
  if [[ $REPLY == "0" ]]; then
      echo 'Exiting!' >&2
      exit
  elif [[ -z $fileName ]]; then
      echo 'Invalid choice, try again' >&2
  else
      # Use the selected index to get the full file path
      scratchDef=${scratchDefFiles[$((REPLY-1))]}
      break
  fi
done

update_or_add_var "oc_scratchDef" "${oc_configFileName}" $scratchDef

echo "Config file has been written to ${oc_configFileName}, you can update your defaults at anytime by running "oc config"."
echo "Continuing..."