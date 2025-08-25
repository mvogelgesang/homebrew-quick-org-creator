#!/bin/bash

_message "Creating a new scratch org...\n"

# check if org-only flag "-o" is passed
ORG_ONLY=false
while getopts "o" opt; do
  case ${opt} in
    o )
      # If the -o flag is found, user just wants the org
      ORG_ONLY=true
      ORG_ONLY_HEADER="
      -------------------
      -- org-only mode --
      -------------------
      "
      _message $ORG_ONLY_HEADER
      ;;
    \? )
      # Handle any unknown flags.
      _message "warning" "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

# DEV HUB
if [ -z "${oc_devHubArray[*]}" ]
then
  _message "question" "DevHub (leave blank for default \"$oc_devHub\")"
  read alias
else
  _message "question" "DevHub (enter 0 for default \"$oc_devHub\")"
  select dh in "${oc_devHubArray[@]}"; do
    if [ $REPLY == "0" ]; then
      alias=$oc_devHub
      break;
    elif [[ -n $dh ]]; then
      alias=$dh
      break;
    else
      _message "warn" "Invalid selection, try again" >&2
    fi
  done
fi
oc_devHub=$alias

_message "This script will create a new scratch org off of $oc_devHub.\n"

# PROJECT / ORG ALIAS
_message "question" "What is the alias for the org? This might be a Org62 case number (37711301-pushUpgrades), trailhead exercise, etc."
read oc_alias
oc_datedAlias+=$oc_alias

# SCRATCH DEFINITION
_message "question" "\nScratch Definition (Enter 0 for default "$oc_scratchDef")"
  select file in "${oc_installedDir}/..scratchDefs/"*.json; do
    if [ $REPLY == "0" ]; then
      _message Default chosen
      break;
    elif [[ -z $file ]]; then
      _message "warn" "Invalid selection, try again" >&2
    else
      oc_scratchDef=$file
      break;
    fi
done
_message "Scratch definition set: $oc_scratchDef"

# MERGE SCRATCH DEFINITION WITH DEFAULTS
TMP_SCRATCH_DEF=$(mktemp)
trap 'rm -f "$TMP_SCRATCH_DEF"' EXIT

if [ -f "$oc_defaultScratchDefFile" ]; then
  _message "Applying scratch org default values/settings from $oc_defaultScratchDefFile"
  mergeScratchDef "$oc_scratchDef" "$oc_defaultScratchDefFile" "$TMP_SCRATCH_DEF"
  oc_scratchDef="$TMP_SCRATCH_DEF"
fi


if ! $ORG_ONLY; then
  # PROJECT DIRECTORY 
  _message "question" "\nWhat folder should this go in? (Leave blank for default $oc_folder)"
  read f
  if [ ! -z "$f" ]
    then
      # ~ is not automatically expanded, first we do that. If an absolute path is provided, thats ok too
      f="${f/#\~/$HOME}"
      oc_folder=$f
  fi
fi

# NAMESPACE
_message "question" "\nLet's setup a namespace for the new project. To store a list of namespaces, run \"oc namespace\""

  if [ -z "${oc_namespaceArray[*]}" ]
  then
    read -p "Enter namespace (leave blank for none): " namespace
  else
    _message "question" "Select a namespace from the list (enter 0 to not set a namespace):"
    select ns in "${oc_namespaceArray[@]}"; do
      if [ $REPLY == "0" ]; then
        namespace=""
        break;
      elif [[ -n $ns ]]; then
        namespace=$ns
        break;
      else
        _message "warn" "Invalid selection, try again" >&2
      fi
    done
  fi

  if [ -z "$namespace" ]
  then
    _message "No namespace has been set for this project."
    nsFlag=""
  else
    _message "The namespace for this project is set to $namespace."
    nsFlag="-s $namespace"
  fi

# SCRATCH ORG DURATION 
duration_input_valid=false
while [ "$duration_input_valid" = false ]; do
    _message "question" "\nSet scratch org duration (1-30), leave blank for default ($oc_duration)."
    read days

    if [ -z "$days" ] && [ ! -z "$oc_duration" ]; then
      duration_input_valid=true
    # Check if input is an integer and between 1 and 30
    elif [[ "$days" =~ ^[0-9]+$ ]] && [ "$days" -ge 1 ] && [ "$days" -le 30 ]; then
        duration_input_valid=true
        oc_duration=$days
    else
        _message "warn" "Please enter a number between 1 and 30."
    fi
done

if ! $ORG_ONLY; then
  # GITHUB
  if [ -z "${oc_remoteNames[*]}" ]
  then
    _message "question" "Git Remote (leave blank for default \"$oc_defaultRemote\")"
    read remote
  else
    _message "question" "DevHub (enter 0 for default \"$oc_defaultRemote\")"
    select r in "${oc_remoteNames[@]}"; do
      if [ $REPLY == "0" ]; then
        remote=$oc_defaultRemote
        break;
      elif [[ -n $r ]]; then
        remote=$r
        break;
      else
        _message "warn" "Invalid selection, try again" >&2
      fi
    done
  fi
  oc_githubRemote=$remote
fi

_message "This script will create a new scratch org off of $oc_devHub."

if ! $ORG_ONLY; then
  # CREATE PROJECT

  _message "\nGenerating project"
  sf project generate -t standard -n $oc_datedAlias -d $oc_folder $nsFlag
  cd $oc_folder/$oc_datedAlias

  # COPY SCRATCH DEF INTO PROJECT
  cp -f $oc_scratchDef $oc_folder/$oc_datedAlias/config/project-scratch-def.json

  # UPDATE README
  _message "question" "Describe this goals for this project"
  read goals
  echo "# ${oc_alias}" > $oc_folder/$oc_datedAlias/README.md
  echo "" >> $oc_folder/$oc_datedAlias/README.md
  echo $goals >> $oc_folder/$oc_datedAlias/README.md
fi 
# CREATE SCRATCH
sf org create scratch -f $oc_scratchDef -a $oc_alias -v $oc_devHub -w 10 -y $oc_duration
_message "Scratch org creation done"

# OPEN IDE & SET TARGET ORG
if ! $ORG_ONLY; then
  open_ide $oc_folder/$oc_datedAlias -g $oc_folder/$oc_datedAlias/README.md:2
fi
_message "Setting default org target"
sf config set target-org=$oc_alias

# PW RESET
_message "Resetting the password"
sf org generate password --complexity 3

# OPEN ORG
_message "Opening the new org"
sf org open -o $oc_alias

if ! $ORG_ONLY; then
  # PROJECT UPDATE
  _message "Creating pre-commit hook for Code Analyzer"
  echo -e "// lint-staged.config.js
  module.exports = {
    \"**/*.cls\": (filenames) => \"sf scanner run -f table -s 3 -t \" + filenames.join(\", \") 
  };
  " > lint-staged.config.js

  _message "Creating GitHub Action Workflow Rules"
  mkdir -p .github/workflows
  cp -a "${oc_installedDir}/../fileTemplates/workflows/." .github/workflows/

  # GITHUB REPO
  if $oc_github
  then
    _message "Creating a git repo locally and on GitHub"
    git init 
    custom_host=false
    # if oc_githubRemote 
    for i in "${!oc_remoteNames[@]}"; do
      if [ "${oc_remoteNames[$i]}" == "$oc_githubRemote" ]; then
        custom_host=true
        if [ "${oc_remoteUrls[$i]}" != "" ]; then
          export GH_HOST="${oc_remoteUrls[$i]}"
        fi
        break
      fi
    done
    gh repo create $oc_datedAlias --private  -s .  --disable-wiki --disable-issues
  else
    _message "Github CLI not setup, skipping Git-related steps"
  fi

  # INSTALL DEPENDENCIES
  _message "Installing dependencies"
  npm i
fi 