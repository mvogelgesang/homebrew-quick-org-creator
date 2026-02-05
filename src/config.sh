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
    open_ide $oc_defaultScratchDefFile
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

# IDE PREFERENCE CONFIGURATION
# Check if we have the upgrade system loaded (for new users going through config)
if declare -f prompt_ide_configuration > /dev/null; then
  _message "question" "\nLet's configure your preferred IDE:"
  prompt_ide_configuration
else
  # Fallback for standalone config runs
  _message "question" "\nChoose your preferred IDE:"
  select ide in "VSCode" "Cursor"; do
    if [[ $REPLY == "1" ]]; then
      preferred_ide="vscode"
      break;
    elif [[ $REPLY == "2" ]]; then
      preferred_ide="cursor"
      break;
    else
      _message "warn" "Invalid selection, try again" >&2
    fi
  done
  
  update_or_add_var "oc_preferredIDE" "${oc_configFileName}" $preferred_ide
fi

# CUSTOM SKILLS PATH CONFIGURATION
_message "question" "\nWould you like to configure a custom Cursor skills folder? (y/n)"
_message "This lets you add your own skills that will be copied to new projects alongside the defaults."
read configure_skills

if [[ $configure_skills =~ ^[Yy]$ ]]; then
  _message "question" "Enter the path to your custom skills folder (e.g., ~/my-cursor-skills):"
  _message "The folder should contain subdirectories, each with a skill.md file."
  read skills_path
  
  if [ -n "$skills_path" ]; then
    # Expand ~ for validation
    expanded_path="${skills_path/#\~/$HOME}"
    if [ -d "$expanded_path" ]; then
      update_or_add_var "oc_customSkillsPath" "${oc_configFileName}" "$skills_path"
      _message "success" "Custom skills path set to: $skills_path"
      
      # Show what skills were found
      skill_count=0
      for skill_dir in "$expanded_path"/*/; do
        if [ -d "$skill_dir" ] && [ -f "$skill_dir/skill.md" ]; then
          skill_name=$(basename "$skill_dir")
          _message "  • Found skill: $skill_name"
          ((skill_count++))
        fi
      done
      
      if [ $skill_count -eq 0 ]; then
        _message "warn" "No skills found. Ensure each skill is in a subdirectory with a skill.md file."
      else
        _message "success" "Found $skill_count custom skill(s)"
      fi
    else
      _message "warn" "Directory not found: $expanded_path"
      _message "Skipping custom skills configuration."
    fi
  fi
else
  # Clear any existing custom skills path if user says no
  update_or_add_var "oc_customSkillsPath" "${oc_configFileName}" ""
fi

_message "success" "\nConfig file has been written to ${oc_configFileName}."

# Update the config version to prevent upgrade prompts after manual config
if [ -f "${oc_installedDir}/VERSION" ]; then
  current_version=$(cat ${oc_installedDir}/VERSION)
  update_or_add_var "oc_lastConfigVersion" "${oc_configFileName}" "$current_version"
fi

_message "You can update your defaults at anytime by running \"oc config\"."
_message "Continuing..."