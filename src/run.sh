#!/bin/bash

## Script variables, update as necessary ##
export oc_alias=""
export oc_datedAlias=$(date '+%Y%m%d')_
export oc_update="N"
export oc_installedDir="$(brew --prefix quick-org-creator)/libexec"
export oc_configFilePath="$HOME/.quick-org-creator/"
export oc_configFileName="${oc_configFilePath}.config"
export oc_github=false
export oc_currentWorkingDirectory=$(pwd)


## Colors
export oc_COLOR_WHITE='\033[0;37m' #cWhite
# ='\033[0;34m'  #cBlue
# ='\033[0;36m' #cCyan
export oc_COLOR_QUESTION='\033[0;96m' #cLightCyan
#='\033[0;94m' #cLightBlue
export oc_COLOR_SUCCESS='\033[0;32m' #cGreen
export oc_COLOR_WARN='\033[0;33m' #cYellow
export oc_COLOR_THEME='\033[0;35m' #cMagenta
export oc_COLOR_ERROR='\033[0;31m' #cRed
export oc_COLOR_NOTIFICATION='\033[0;44m' #bBlue
#='\033[0;46m' #bCyan
#='\033[0;104m' #bLightBlue
#='\033[0;106m' #bLightCyan
export oc_COLOR_NOCOLOR='\033[0;0m' #cNoColor
export oc_arrow="  -> "
version=$(cat ${oc_installedDir}/VERSION)

echo -e "${oc_COLOR_THEME}
===================================================
 __   __   __      __   __   ___      ___  __   __  
/  \ |__) / _\`    /  \` |__) |__   /\   |  /  \ |__) 
\__/ |  \ \__>    \__, |  \ |___ /~~\  |  \__/ |  \\
=================================================== 
${oc_COLOR_NOCOLOR}"                                                    

source "${oc_installedDir}/dependencies.sh"

if [ $? -eq 1 ]
then
  exit 1
fi

if test -f "${oc_configFileName}"; then
  source "${oc_configFileName}"
  else
  echo -e "${oc_COLOR_WARN}It looks like a config file is not setup, let's create one...${oc_COLOR_NOCOLOR}"
  source "${oc_installedDir}/config.sh"
  source "${oc_configFileName}"
fi

# Check for updates
if brew outdated | grep -q '^quick-org-creator '; then
  echo "An update for mvogelgesang/quick-org-creator is available. You can update it with 'brew upgrade mvogelgesang/quick-org-creator'."
fi

arg=$1
arg=$(echo $arg | tr '[:upper:]' '[:lower:]')

case $arg in
  "namespace")
    echo "Updating namespace list"
    source "${oc_installedDir}/namespace.sh"
    ;;
  "config")
    echo "Opening config editor"
    source "${oc_installedDir}/config.sh"
    ;;
  "devhub")
    echo "Updating DevHub list"
    source "${oc_installedDir}/devHub.sh"
    ;;
  "--version")
    echo $version
    ;;
  *)
    source "${oc_installedDir}/create.sh"
    ;;
esac


