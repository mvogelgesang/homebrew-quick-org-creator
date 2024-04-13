#!/bin/bash

## Script variables, update as necessary ##
export oc_alias=""
export oc_datedAlias=$(date '+%Y%m%d')_
export oc_update="N"
export oc_installedDir="`dirname $0`"
export oc_configFilePath="${oc_installedDir}/../.config"
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



sh "${oc_installedDir}/create.sh"