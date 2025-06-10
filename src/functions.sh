#!/bin/bash

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
export oc_TITLE="
===================================================
 __   __   __      __   __   ___      ___  __   __  
/  \ |__) / _\`    /  \` |__) |__   /\   |  /  \ |__) 
\__/ |  \ \__>    \__, |  \ |___ /~~\  |  \__/ |  \\
=================================================== 
"

# Function to update config variables
update_or_add_var() {
  local var_name=$1
  local config_file=$2
  shift 2
  local var_value=("$@")
  # local var_value_string=$(IFS=" "; echo "${var_value[*]}")

  # Check if the last argument is an array or a string
  if [ "${var_value[0]}" = "${var_value[*]}" ]; then
    # If it's a string, just use it as is
    local var_value_string="${var_value[0]}"
  else
    # If it's an array, convert it to a string, make sure any empty strings are converted to double quotes
    local var_value_string="($(IFS=" "; for val in "${var_value[@]}"; do [[ -z "$val" ]] && echo -n '"" ' || echo -n "$val "; done))"
  fi

  if grep -q "${var_name}=" "$config_file"; then
    # If it exists, replace it (using # as a sed delimiter rather than the traditional /)
    sed -i "" "s#$var_name=.*#$var_name=$var_value_string#" "$config_file"
  else
    # If it doesn't exist, add it
    echo -e "\nexport $var_name=$var_value_string" >> "$config_file"
  fi
}

# A function to echo out pretty messages
# usage:
# _message "type" "message"
#   type?: question, warning, error, header, info
#   message: string to echo out
_message() {
  # If only one argument is provided, default the TYPE to "info"
  # and treat the single argument as the MESSAGE.
  if [ "$#" -eq 1 ]; then
    set -- "info" "$1"
  fi

  local TYPE="$1"
  local MESSAGE="$2"
  TYPE=$1
  MESSAGE=$2

  case $TYPE in
    "error")
      echo -e "${oc_COLOR_ERROR}${MESSAGE}${oc_COLOR_NOCOLOR}" >&2
      ;;
    "notification")
      echo -e "${oc_COLOR_NOTIFICATION}${MESSAGE}${oc_COLOR_NOCOLOR}"
      ;;
    "question")
      echo -e "${oc_COLOR_QUESTION}${MESSAGE}${oc_COLOR_NOCOLOR}"
      ;;
    "success")
      echo -e "${oc_COLOR_SUCCESS}${MESSAGE}${oc_COLOR_NOCOLOR}" >&2
      ;;
    "theme")
      echo -e "${oc_COLOR_THEME}${MESSAGE}${oc_COLOR_NOCOLOR}" >&2
      ;;
    "warn")
      echo -e "${oc_COLOR_WARN}${MESSAGE}${oc_COLOR_NOCOLOR}" >&2
      ;;
    *)
      # Default case for info, headers, etc.
      echo -e "${MESSAGE}"
      ;;
  esac
}