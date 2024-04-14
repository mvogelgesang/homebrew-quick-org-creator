#!/bin/bash

## update check https://www.christianengvall.se/check-for-changes-on-remote-origin-git-repository/
echo "Checking for updates..."
git fetch
 HEADHASH=$(git rev-parse HEAD)
 UPSTREAMHASH=$(git rev-parse main@{upstream})

 if [ "$HEADHASH" != "$UPSTREAMHASH" ]
 then
   echo -e "${oc_COLOR_NOTIFICATION}Updates available, do you want to update? \[Y/N\]${oc_COLOR_NOCOLOR}"
   read u
    if [ "$u" == "Y" ] || [ "$u" == "y" ]
      then
        echo "Updating..."
        git pull origin main
        echo -e ${oc_COLOR_WHITE}Since last update...${oc_COLOR_NOCOLOR}
        git log HEAD..origin/main --oneline
    fi
 else
   echo -e "${oc_COLOR_WHITE}Up to date!${oc_COLOR_NOCOLOR}"
 fi

## Start script
# echo -e "${oc_COLOR_QUESTION}DevHub (leave blank for default $oc_devHub)${oc_COLOR_NOCOLOR}"
# read o
# if [ ! -z "$o" ]
#   then
#     oc_devHub=$o
# fi

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



# read in name of project
echo ""
echo -e "${oc_COLOR_QUESTION}What is the alias for the org? This might be a Org62 case number (37711301-pushUpgrades), trailhead exercise, etc.${oc_COLOR_NOCOLOR}"
read oc_alias
oc_datedAlias+=$oc_alias

# user can override the scratch definition if desired
echo ""
echo -e "${oc_COLOR_QUESTION}Scratch Definition (Enter 0 for default "$oc_scratchDef")${oc_COLOR_NOCOLOR}"
  select file in "${oc_installedDir}/../..scratchDefs/"*.json; do
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

# default parent folder is set but can be overridden
echo ""
echo -e "${oc_COLOR_QUESTION}What folder should this go in? (Leave blank for default $oc_folder)${oc_COLOR_NOCOLOR}"
read f
if [ ! -z "$f" ]
  then
    folder=$f
fi

# echo "Devhub: $devHub"
# echo "scratchDef: $scratchDef"
# echo "alias: $oc_alias"

# create the scratch org and project folder. 
# Once done, open folder in code and install dependencies
sf org create scratch -f $oc_scratchDef -a $oc_alias -v $oc_devHub -w 10 -y 21

echo "Scratch org creation done"

echo ""
echo -e "${oc_COLOR_QUESTION}Let's setup a namespace for the new scratch org. To store a list of namespaces, run `oc namespace`${oc_COLOR_NOCOLOR}"

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

echo ""
echo "Setting target-org and generating project"
sf project generate -t standard -n $oc_datedAlias -d $oc_folder $nsFlag

# write the readme
echo -e "${oc_COLOR_QUESTION}Describe this goals for this project${oc_COLOR_NOCOLOR}"
read goals
echo "# ${oc_alias}" > $oc_folder/$oc_datedAlias/README.md
echo "" >> $oc_folder/$oc_datedAlias/README.md
echo $goals >> $oc_folder/$oc_datedAlias/README.md

# open code editor
code $oc_folder/$oc_datedAlias -g $oc_folder/$oc_datedAlias/README.md:2
cd $oc_folder/$oc_datedAlias
sf config set target-org=$oc_alias
echo "Resetting the password"
sf org generate password --complexity 3
echo "Installing dependencies"
npm i

echo "Creating pre-commit hook for Code Analyzer"
echo -e "// lint-staged.config.js
module.exports = {
  \"**/*.cls\": (filenames) => \"sf scanner run -f table -s 3 -t \" + filenames.join(\", \") 
};
" > lint-staged.config.js

echo "Creating GitHub Action Workflow Rules"
mkdir -p .github/workflows
cp -a "${oc_installedDir}/../fileTemplates/workflows/." .github/workflows/

if $oc_github
then
  echo "Creating a git repo locally and on GitHub"
  git init 
  gh repo create $oc_datedAlias --private  -s .  --disable-wiki --disable-issues
else
  echo "Github CLI not setup, skipping Git-related steps"
fi

echo "Opening the new org"
sf org open -o $oc_alias
