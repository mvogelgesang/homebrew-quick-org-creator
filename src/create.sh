#!/bin/bash

_message "Creating a new scratch org...\n"

# check if org-only flag "-o" is passed
ORG_ONLY=false
USE_DEFAULTS=false
RELEASE_PREVIEW=false
NON_OPTION_ARGS=()

for arg in "$@"; do
  case "$arg" in
    -y)
      USE_DEFAULTS=true
      ;;
    -o)
      ORG_ONLY=true
      ;;
    -p)
      RELEASE_PREVIEW=true
      ;;
    -*)
      _message "error" "Unknown option: $arg" >&2
      exit 1
      ;;
    *)
      NON_OPTION_ARGS+=("$arg")
      ;;
  esac
done

oc_alias="${NON_OPTION_ARGS[0]}"

if $USE_DEFAULTS; then
    _message "
    -------------------
    -- default mode --
    -------------------
    "
    if [ -z "$oc_alias" ]; then
        _message "error" "Error: Alias is required for default mode (e.g. oc -y my-alias)." >&2
        exit 1
    fi
fi

# DEV HUB
if ! $USE_DEFAULTS; then
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
fi

_message "This script will create a new scratch org off of $oc_devHub.\n"

# PROJECT / ORG ALIAS
if ! $USE_DEFAULTS; then
  _message "question" "What is the alias for the org? This might be a Org62 case number (37711301-pushUpgrades), trailhead exercise, etc."
  read oc_alias
fi
oc_datedAlias+=$oc_alias

# SCRATCH DEFINITION
if ! $USE_DEFAULTS; then
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
fi
_message "Scratch definition set: $oc_scratchDef"

# Store the original scratch def file for display purposes
display_scratchDef="$oc_scratchDef"

# MERGE SCRATCH DEFINITION WITH DEFAULTS
TMP_SCRATCH_DEF=$(mktemp)
trap 'rm -f "$TMP_SCRATCH_DEF"' EXIT

if [ -f "$oc_defaultScratchDefFile" ]; then
  _message "Applying scratch org default values/settings from $oc_defaultScratchDefFile"
  mergeScratchDef "$oc_scratchDef" "$oc_defaultScratchDefFile" "$TMP_SCRATCH_DEF"
  oc_scratchDef="$TMP_SCRATCH_DEF"
fi

# ADD RELEASE PREVIEW IF FLAG IS SET
if $RELEASE_PREVIEW; then
  _message "Adding release preview setting to scratch definition"
  # Create a new temporary file for the modified scratch def
  TMP_PREVIEW_DEF=$(mktemp)
  trap 'rm -f "$TMP_PREVIEW_DEF"' EXIT
  
  # Use jq to add the "release": "preview" property
  jq '. + {"release": "preview"}' "$oc_scratchDef" > "$TMP_PREVIEW_DEF"
  oc_scratchDef="$TMP_PREVIEW_DEF"
fi


if ! $ORG_ONLY; then
  if ! $USE_DEFAULTS; then
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
fi

# NAMESPACE
if ! $USE_DEFAULTS; then
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
else
  namespace=""
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
if ! $USE_DEFAULTS; then
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
fi

if ! $ORG_ONLY; then
  # GITHUB
  if ! $USE_DEFAULTS; then

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
  else
    oc_githubRemote=$oc_defaultRemote
  fi
fi

if $USE_DEFAULTS; then
  _message "theme" "\n--- Configuration for new org ---"
  printf "%-28s: %s\n" "Alias" "$oc_alias"
  printf "%-28s: %s\n" "Dev Hub" "$oc_devHub"
  printf "%-28s: %s\n" "Scratch Definition" "$(basename "$display_scratchDef")"
  if ! $ORG_ONLY; then
    printf "%-28s: %s\n" "Project Path" "$oc_folder/$oc_datedAlias"
  fi
  printf "%-28s: %s\n" "Namespace" "${namespace:-None}"
  printf "%-28s: %s\n" "Duration" "$oc_duration days"
  if $RELEASE_PREVIEW; then
    printf "%-28s: %s\n" "Release Preview" "Enabled"
  fi
  if ! $ORG_ONLY && [ -n "$oc_githubRemote" ]; then
    printf "%-28s: %s\n" "GitHub Remote" "$oc_githubRemote"
  fi
  _message "theme" "--------------------------------------"

  _message "question" "Proceed with these settings? (y/n)"
  read -r confirmation
  if [[ ! "$confirmation" =~ ^[Yy]$ ]]; then
      _message "warn" "Aborted by user."
      exit 1
  fi
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
  if ! $USE_DEFAULTS; then
    _message "question" "Describe this goals for this project"
    read goals
  else
    goals="Project created in unattended mode"
  fi
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
  cp -a "${oc_installedDir}/fileTemplates/workflows/." .github/workflows/

  _message "Creating .cursor/skills directory"
  cp -a "${oc_installedDir}/fileTemplates/.cursor" .

  # Copy custom skills if configured
  if [ -n "$oc_customSkillsPath" ] && [ -d "$oc_customSkillsPath" ]; then
    _message "Adding custom skills from $oc_customSkillsPath"
    # Expand ~ if present
    expanded_path="${oc_customSkillsPath/#\~/$HOME}"
    if [ -d "$expanded_path" ]; then
      # Copy each subdirectory from custom skills path into .cursor/skills/
      for skill_dir in "$expanded_path"/*/; do
        if [ -d "$skill_dir" ]; then
          skill_name=$(basename "$skill_dir")
          cp -a "$skill_dir" ".cursor/skills/"
          _message "  • Added skill: $skill_name"
        fi
      done
    else
      _message "warn" "Custom skills path not found: $expanded_path"
    fi
  fi

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