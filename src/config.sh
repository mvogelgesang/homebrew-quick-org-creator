#!/bin/bash
source ${oc_installedDir}/functions.sh

devhub=''
folderPath=''
scratchDef=''

source ${oc_installedDir}/devHub.sh
source ${oc_installedDir}/../.config

echo ""

if [ -z "${oc_devHubArray[*]}" ]
then
  echo -e "${oc_COLOR_QUESTION}What alias should be used as your default dev hub org${oc_COLOR_NOCOLOR}"
  read alias
else
  echo "Pick a default devHub from the list of authenticated devhubs:"
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
update_or_add_var "oc_devHub" "${oc_installedDir}/../.config" $alias


echo ""
echo -e "${oc_COLOR_QUESTION}What folder should projects be created in? (Enter full path ~/myfolder/path${oc_COLOR_NOCOLOR}"
read folderPath
folder=$folderPath
update_or_add_var "oc_folder" "${oc_installedDir}/../.config" $folder


echo ""
echo -e "${oc_COLOR_QUESTION}Would you like to set a default scratch org definition file?${oc_COLOR_NOCOLOR}"
select file in ..scratchDefs/*.json; do
  if [[ $REPLY == "0" ]]; then
      echo 'Exiting!' >&2
      exit
  elif [[ -z $file ]]; then
      echo 'Invalid choice, try again' >&2
  else
      scratchDef=$file
      break
  fi
done
update_or_add_var "oc_scratchDef" "${oc_installedDir}/../.config" $scratchDef


  
export oc_devHub=$devhub
export oc_folder=$folder
  " >> ${oc_installedDir}/../.config


echo "Config file has been written to .config, you can update your defaults at anytime by running "oc config"."
echo "Continuing..."