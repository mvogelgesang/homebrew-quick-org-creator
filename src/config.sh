#!/bin/bash
source ${oc_installedDir}/functions.sh

devhub=''
folderPath=''
scratchDef=''

mkdir -p $oc_configFilePath
touch $oc_configFileName

source ${oc_installedDir}/devHub.sh
source $oc_configFileName

_message "theme" "
------------------------------
=======CONFIG EDITOR==========
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
"       

if [ -z "${oc_devHubArray[*]}" ]
then
  _message "question" "What alias should be used as your default dev hub org"
  read alias
else
  _message "question" "Pick a default devHub from the list of authenticated devhubs:"
  select dh in "${oc_devHubArray[@]}"; do
    if [ $REPLY == "0" ]; then
      alias=""
      break;
    elif [[ -n $dh ]]; then
      alias=$dh
      break;
    else
      _message "warn" "Invalid selection, try again" >&2
    fi
  done
fi
update_or_add_var "oc_devHub" "${oc_configFileName}" $alias

_message "question" "\nWhat folder should projects be created in? (Enter full path ~/myfolder/path)"
read folderPath
folder=$folderPath
update_or_add_var "oc_folder" "${oc_configFileName}" $folder

_message "question" "\nWould you like to set a default scratch org definition file?"

scratchDefFiles=(${oc_installedDir}/..scratchDefs/*.json)
scratchDefFileNames=()
for file in "${scratchDefFiles[@]}"; do
  scratchDefFileNames+=("$(basename "$file")")
done

select fileName in "${scratchDefFileNames[@]}"; do
  if [[ $REPLY == "0" ]]; then
      _message 'Exiting!' >&2
      exit
  elif [[ -z $fileName ]]; then
      _message "warn" 'Invalid choice, try again' >&2
  else
      # Use the selected index to get the full file path
      scratchDef=${scratchDefFiles[$((REPLY-1))]}
      break
  fi
done

update_or_add_var "oc_scratchDef" "${oc_configFileName}" $scratchDef

_message "question" "Do you want to update default settings/ features for scratch definition files (y/n)?"
read updateDefaultScratchDef
  if [[ $updateDefaultScratchDef =~ ^[Yy]$ ]]; then
    if [ ! -f "$oc_defaultScratchDefFile"]; then
      _message "Default scratch def not found, preparing file..."
      echo -e "{}" > "$oc_defaultScratchDefFile"
    fi
    _message "Opening default scratch def file...\n"
    code $oc_defaultScratchDefFile
  else
    break
  fi

# SCRATCH ORG DURATION DEFAULT
duration_input_valid=false
while [ "$duration_input_valid" = false ]; do
    _message "question" "\nSet a default number of days before org expires (1-30)."
    read days

    # Check if input is an integer and between 1 and 30
    if [[ "$days" =~ ^[0-9]+$ ]] && [ "$days" -ge 1 ] && [ "$days" -le 30 ]; then
        duration_input_valid=true
        update_or_add_var "oc_duration" "${oc_configFileName}" $days
    else
        _message "warn" "Please enter a number between 1 and 30."
    fi
done

_message "success" "\nConfig file has been written to ${oc_configFileName}."
_message "You can update your defaults at anytime by running \"oc config\"."
_message "Continuing..."