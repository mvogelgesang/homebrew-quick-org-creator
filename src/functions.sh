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

# merge two scratch definition files
# The merged content is stored in a temporary file that is cleaned up once the complete script is executed
#
# Usage:
# mergeScratchDef selectedTemplate.json defaultSettings.json

mergeScratchDef() {

  # --- 1. Input and Dependency Validation ---
  # Ensure two arguments are provided
  if [ "$#" -ne 3 ]; then
      _message "warn" "Error: Invalid number of arguments."
      _message "Usage: $0 <base_file.json> <override_file.json> <tempfile>"
      exit 1
  fi

  BASE_FILE="$1"
  OVERRIDE_FILE="$2"
  FINAL_TEMP_FILE="$3"

  # Check if jq is installed
  if ! command -v jq &> /dev/null; then
      _message "error" "Error: jq is not installed. Please install it to continue."
      _message "On macOS: brew install jq"
      _message "On Debian/Ubuntu: sudo apt-get install jq"
      exit 1
  fi

  # Check if input files exist
  if [ ! -f "$BASE_FILE" ] || [ ! -f "$OVERRIDE_FILE" ]; then
      _message "error" "Error: One or both input files could not be found."
      exit 1
  fi


  # --- 2. Temporary File and Cleanup ---

  # Create a temporary file that will be automatically cleaned up.
  # mktemp creates a unique, secure temporary file.
  TMP_FILE=$(mktemp)
  

  # Set up a "trap" to automatically remove the temporary file when the script exits.
  # This ensures cleanup happens even if the script fails or is interrupted.
  trap 'rm -f "$TMP_FILE"' EXIT

  # --- 3. Merging Logic ---

  # -----------------------------------------------------------------------------
  # MERGE LOGIC
  #
  # This jq command merges the two JSON files ($BASE_FILE and $OVERRIDE_FILE)
  # giving precedence to the second file for any conflicting keys.
  #
  # It applies special logic for the "features" array to handle overrides for
  # "key:value" formatted strings. For any given key (the text before a colon),
  # the version from the override file will be the one present in the final output.
  #
  # How it works:
  #
  # 1. `$final_features` variable:
  #    First, it calculates the correct final state of the 'features' array
  #    and stores it in a variable named `$final_features`.
  #    a. It concatenates the 'features' arrays from both files, ensuring that
  #       the override elements come after the base elements.
  #    b. It then pipes this combined array through a filter that converts it
  #       into a temporary object, using the text before any colon as the key.
  #       This process de-duplicates the entries, as later values (from the
  #       override file) overwrite earlier ones with the same key.
  #    c. Finally, it converts the de-duplicated object's values back into a
  #       clean array.
  #
  # 2. Final Merge:
  #    It performs a standard recursive merge ('*') on the two files and then
  #    replaces the resulting 'features' key with the correct array that was
  #    stored in the `$final_features` variable.
  # -----------------------------------------------------------------------------
  jq -s '
    # First, calculate the correctly merged "features" array and store it in a variable.
    (
      # Safely get and concatenate the features arrays from both files.
      (.[0].features // []) + (.[1].features // []) 
      # Apply the new key-based merging logic.
      | (map({(.|split(":")[0]):.}) | add | values)
    ) as $final_features |

    # Now, do the simple merge and immediately set the features key to our variable.
    (.[0] * .[1] | .features = $final_features)
  ' "$BASE_FILE" "$OVERRIDE_FILE" > "$TMP_FILE"
  
  # Extract values from the resultant features object into an array
  # delete the existing features object
  # replace with features as an array, write to a new temporary file
  jq '[(.features[] | values)] as $featuresArray | del(.features) + { "features": $featuresArray }' "$TMP_FILE" > "$FINAL_TEMP_FILE"


  # Check if jq command was successful
  if [ $? -ne 0 ]; then
      _message "error" "Error: jq merge command failed. Check if JSON files are valid."
      # The 'trap' will still clean up the temp file upon exit.
      exit 1
  fi
}

#
# Prints a formatted list from an array of strings.
# @param {string} title   The title to print above the list.
# @param {array}  ...     All subsequent arguments are the array elements.
#
# Usage:
#   local my_array=("apple" "banana" "cherry")
#   print_array "My Fruit List" "${my_array[@]}"
#
print_array() {
  # The first argument is the title.
  local title="$1"
  shift # Remove the title from the argument list.

  # All remaining arguments are now the array items.
  # We can store them in a local array.
  local items=("$@")

  # Print a header for the list.
  _message "$title"

  # Check if the array is empty.
  if [ ${#items[@]} -eq 0 ]; then
    printf "  <empty>\n"
    return
  fi

  # Loop through the items and print each one.
  for item in "${items[@]}"; do
    printf "  - %s\n" "$item"
  done
}

#
# Prints two arrays side-by-side in a table.
# This version is compatible with older versions of Bash (pre-4.3).
#
# @param {string} title       Title for the overall table.
# @param {string} col1title   Title for the first column.
# @param {string} array1_name The NAME of the first array variable.
# @param {string} col2title   Title for the second column.
# @param {string} array2_name The NAME of the second array variable.
#
# Usage:
#   local arr1=("a" "b" "c")
#   local arr2=("x" "y")
#   print_arrays_parallel "My title" "Col 1" arr1 "Col 2" arr2
#
print_arrays_parallel() {
  local title="$1"
  local col1title="$2"
  local array1_name="$3"
  local col2title="$4"
  local array2_name="$5"

  # To get the length of the arrays using their names, we use 'eval'.
  # This is a safe use of eval as the variable names are controlled by the script.
  local len1=$(eval echo "\${#$array1_name[@]}")
  local len2=$(eval echo "\${#$array2_name[@]}")
  local max_len=$(( len1 > len2 ? len1 : len2 ))

  # Print table headers
  _message "--------------------------------------------------------------"
  _message "                        $title"
  _message "--------------------------------------------------------------"
  printf "%-28s | %s\n" "$col1title" "$col2title"
  _message "--------------------------------------------------------------"

  # Loop from 0 to max_len - 1
  for (( i=0; i<max_len; i++ )); do
    # For each array, create a string representing the indexed element,
    # e.g., "my_array[0]", then use indirect expansion '${!ref}' to get its value.
    local item1_ref="${array1_name}[i]"
    local item2_ref="${array2_name}[i]"

    # If the index is out of bounds, the value will be empty.
    local item1="${!item1_ref}"
    local item2="${!item2_ref}"

    # Print the formatted row
    printf "%-28s | %s\n" "$item1" "$item2"
  done
  _message "--------------------------------------------------------------\n"
}

# Get the CLI command for the configured IDE
# Returns "code" for VSCode or "cursor" for Cursor
# Defaults to "code" if oc_preferredIDE is not set
get_ide_command() {
  local ide="${oc_preferredIDE:-vscode}"
  case $ide in
    "cursor")
      echo "cursor"
      ;;
    *)
      echo "code"
      ;;
  esac
}

# Get the display name for the configured IDE
get_ide_display_name() {
  local ide="${oc_preferredIDE:-vscode}"
  case $ide in
    "cursor")
      echo "Cursor"
      ;;
    *)
      echo "VSCode"
      ;;
  esac
}

# Check if the configured IDE CLI is available
check_ide_available() {
  local ide_command=$(get_ide_command)
  local ide_name=$(get_ide_display_name)
  
  if ! command -v $ide_command &> /dev/null; then
    _message "warn" ">> $ide_name \`$ide_command\` terminal command not found, you will have to launch your editor manually."
    case $ide_command in
      "code")
        _message ">> To add \`code\` as a terminal command, open VSCode, press CMD+Shift+P, select Install 'code' command in PATH"
        _message ">> If that does not work, see https://github.com/microsoft/vscode/issues/154163"
        ;;
      "cursor")
        _message ">> To add \`cursor\` as a terminal command, open Cursor, press CMD+Shift+P, select Install 'cursor' command in PATH"
        _message ">> If that does not work, see https://docs.cursor.com/get-started/install"
        ;;
    esac
    return 1
  fi
  return 0
}

# Open a file or directory with the configured IDE
# Usage: open_ide <path> [additional_args...]
open_ide() {
  local ide_command=$(get_ide_command)
  
  if check_ide_available; then
    $ide_command "$@"
  else
    _message "warn" "Cannot open with $(get_ide_display_name) - CLI not available. Skipping IDE launch."
    return 1
  fi
}