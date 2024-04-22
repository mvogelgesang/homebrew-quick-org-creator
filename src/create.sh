#!/bin/bash

# DEV HUB
if [ -z "${oc_devHubArray[*]}" ]
then
  echo -e "${oc_COLOR_QUESTION}DevHub (leave blank for default "$oc_devHub")${oc_COLOR_NOCOLOR}"
  read alias
else
  echo -e "${oc_COLOR_QUESTION}DevHub (enter 0 for default "$oc_devHub")${oc_COLOR_NOCOLOR}"
  select dh in "${oc_devHubArray[@]}"; do
    if [ $REPLY == "0" ]; then
      alias=$oc_devHub
      break;
    elif [[ -n $dh ]]; then
      alias=$dh
      break;
    else
      echo -e "${oc_COLOR_WARN}Invalid selection, try again${oc_COLOR_NOCOLOR}" >&2
    fi
  done
fi
oc_devHub=$alias

echo "This script will create a new scratch org off of $oc_devHub."

# PROJECT / ORG ALIAS
echo ""
echo -e "${oc_COLOR_QUESTION}What is the alias for the org? This might be a Org62 case number (37711301-pushUpgrades), trailhead exercise, etc.${oc_COLOR_NOCOLOR}"
read oc_alias
oc_datedAlias+=$oc_alias

# SCRATCH DEFINITION
echo ""
echo -e "${oc_COLOR_QUESTION}Scratch Definition (Enter 0 for default "$oc_scratchDef")${oc_COLOR_NOCOLOR}"
  select file in "${oc_installedDir}/..scratchDefs/"*.json; do
    if [ $REPLY == "0" ]; then
      echo Default chosen
      break;
    elif [[ -z $file ]]; then
      echo -e "${oc_COLOR_WARN}Invalid selection, try again${oc_COLOR_NOCOLOR}" >&2
    else
      oc_scratchDef=$file
      break;
    fi
done
echo Scratch definition set: $oc_scratchDef

# PROJECT DIRECTORY 
echo ""
echo -e "${oc_COLOR_QUESTION}What folder should this go in? (Leave blank for default $oc_folder)${oc_COLOR_NOCOLOR}"
read f
if [ ! -z "$f" ]
  then
    # ~ is not automatically expanded, first we do that. If an absolute path is provided, thats ok too
    f="${f/#\~/$HOME}"
    oc_folder=$f
fi


# NAMESPACE
echo ""
echo -e "${oc_COLOR_QUESTION}Let's setup a namespace for the new project. To store a list of namespaces, run "oc namespace"${oc_COLOR_NOCOLOR}"

  if [ -z "${oc_namespaceArray[*]}" ]
  then
    read -p "Enter namespace (leave blank for none): " namespace
  else
    echo "Select a namespace from the list (enter 0 to not set a namespace):"
    select ns in "${oc_namespaceArray[@]}"; do
      if [ $REPLY == "0" ]; then
        namespace=""
        break;
      elif [[ -n $ns ]]; then
        namespace=$ns
        break;
      else
        echo -e "${oc_COLOR_WARN}Invalid selection, try again${oc_COLOR_NOCOLOR}" >&2
      fi
    done
  fi

  if [ -z "$namespace" ]
  then
    echo "No namespace has been set for this project."
    nsFlag=""
  else
    echo "The namespace for this project is set to $namespace."
    nsFlag="-s $namespace"
  fi

# CREATE PROJECT
echo ""
echo "Generating project"
sf project generate -t standard -n $oc_datedAlias -d $oc_folder $nsFlag
cd $oc_folder/$oc_datedAlias

# UPDATE README
echo -e "${oc_COLOR_QUESTION}Describe this goals for this project${oc_COLOR_NOCOLOR}"
read goals
echo "# ${oc_alias}" > $oc_folder/$oc_datedAlias/README.md
echo "" >> $oc_folder/$oc_datedAlias/README.md
echo $goals >> $oc_folder/$oc_datedAlias/README.md

# CREATE SCRATCH
sf org create scratch -f $oc_scratchDef -a $oc_alias -v $oc_devHub -w 10 -y 21
echo "Scratch org creation done"

# OPEN VS CODE & SET TARGET ORG
code $oc_folder/$oc_datedAlias -g $oc_folder/$oc_datedAlias/README.md:2
echo "Setting default org target"
sf config set target-org=$oc_alias

# PW RESET
echo "Resetting the password"
sf org generate password --complexity 3

# OPEN ORG
echo "Opening the new org"
sf org open -o $oc_alias

# PROJECT UPDATE
echo "Creating pre-commit hook for Code Analyzer"
echo -e "// lint-staged.config.js
module.exports = {
  \"**/*.cls\": (filenames) => \"sf scanner run -f table -s 3 -t \" + filenames.join(\", \") 
};
" > lint-staged.config.js

echo "Creating GitHub Action Workflow Rules"
mkdir -p .github/workflows
cp -a "${oc_installedDir}/../fileTemplates/workflows/." .github/workflows/

# GITHUB REPO
if $oc_github
then
  echo "Creating a git repo locally and on GitHub"
  git init 
  gh repo create $oc_datedAlias --private  -s .  --disable-wiki --disable-issues
else
  echo "Github CLI not setup, skipping Git-related steps"
fi

# INSTALL DEPENDENCIES
echo "Installing dependencies"
npm i