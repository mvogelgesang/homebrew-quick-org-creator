#!/bin/bash
# Upgrade and Migration System for Quick Org Creator
# This script handles version upgrades and configuration migrations
#
# HOW IT WORKS:
# 1. Tracks the last version for which the user completed configuration (oc_lastConfigVersion)
# 2. Compares against current tool version to detect upgrades
# 3. Runs version-specific upgrade tasks when needed
# 4. Validates and fixes configuration issues automatically
#
# HOW TO EXTEND FOR FUTURE RELEASES:
# 1. Add new upgrade tasks in run_upgrade_tasks() following the pattern:
#    if version_lt "$from_version" "X.Y.Z" && ! version_lt "$to_version" "X.Y.Z"; then
#        # Your upgrade tasks here
#    fi
# 2. Add validation logic in validate_and_fix_config() for new config options
# 3. The system automatically handles version tracking and user detection
#
# EDGE CASES HANDLED:
# - New users vs existing users upgrading
# - Invalid configuration values
# - Missing configuration values
# - Users running config manually
# - Version downgrades (gracefully ignored)

# Get the current tool version and last configured version
current_version=$(cat ${oc_installedDir}/VERSION)
last_config_version="${oc_lastConfigVersion:-}"

# Function to compare version strings (returns 0 if v1 < v2, 1 if v1 >= v2)
version_lt() {
    [ "$(printf '%s\n' "$1" "$2" | sort -V | head -n1)" = "$1" ] && [ "$1" != "$2" ]
}

# Function to prompt for IDE configuration for new users or upgrades
prompt_ide_configuration() {
    _message "theme" "
------------------------------
======IDE CONFIGURATION======
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
"
    _message "question" "We've added support for Cursor IDE! Choose your preferred IDE:"
    select ide in "VSCode (default)" "Cursor"; do
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
    _message "success" "IDE preference set to $(get_ide_display_name)"
}

# Function to run specific upgrade tasks based on version
run_upgrade_tasks() {
    local from_version="$1"
    local to_version="$2"
    
    _message "theme" "
------------------------------
=======UPGRADE DETECTED=======
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
"
    _message "Upgrading Quick Org Creator from $from_version to $to_version"
    
    # Version 0.4.0+ - IDE Configuration Support
    if version_lt "$from_version" "0.4.0" && ! version_lt "$to_version" "0.4.0"; then
        _message "\n🆕 New Feature: IDE Configuration Support!"
        _message "You can now choose between VSCode and Cursor as your preferred IDE."
        
        # Check if user already has an IDE preference configured
        if [ -z "${oc_preferredIDE:-}" ]; then
            _message "\nLet's set up your IDE preference..."
            prompt_ide_configuration
        else
            _message "Your current IDE preference: $(get_ide_display_name)"
        fi
    fi
    
    # Add future upgrade tasks here in the same pattern:
    # if version_lt "$from_version" "0.5.0" && ! version_lt "$to_version" "0.5.0"; then
    #     # 0.5.0 upgrade tasks
    # fi
}

# Function to handle first-time setup vs upgrades
handle_version_migration() {
    # If no last config version, this could be first time setup or existing user
    if [ -z "$last_config_version" ]; then
        # Check if they have other config values (indicating existing user)
        if [ -n "${oc_devHub:-}" ] || [ -n "${oc_folder:-}" ] || [ -n "${oc_duration:-}" ]; then
            # Existing user upgrading - treat as upgrade from reasonable version
            _message "Detected existing configuration, performing upgrade migration..."
            run_upgrade_tasks "0.3.9" "$current_version"
        else
            # New user - IDE config will be handled in main config setup
            # Don't show any upgrade messages for truly new users
            :
        fi
    elif version_lt "$last_config_version" "$current_version"; then
        # Clear upgrade case
        run_upgrade_tasks "$last_config_version" "$current_version"
    else
        # User is up to date or somehow ahead, no action needed
        :
    fi
    
    # Update the last config version to current (only if we have a config file)
    if [ -f "${oc_configFileName}" ]; then
        update_or_add_var "oc_lastConfigVersion" "${oc_configFileName}" "$current_version"
    fi
}

# Function to validate and fix configuration issues
validate_and_fix_config() {
    local config_fixed=false
    
    # Fix invalid IDE preferences
    if [ -n "${oc_preferredIDE:-}" ] && [ "$oc_preferredIDE" != "vscode" ] && [ "$oc_preferredIDE" != "cursor" ]; then
        _message "warn" "Invalid IDE preference '$oc_preferredIDE' detected, resetting to 'vscode'"
        update_or_add_var "oc_preferredIDE" "${oc_configFileName}" "vscode"
        config_fixed=true
    fi
    
    # Set default IDE preference if missing (for backward compatibility)
    if [ -z "${oc_preferredIDE:-}" ]; then
        update_or_add_var "oc_preferredIDE" "${oc_configFileName}" "vscode"
        config_fixed=true
    fi
    
    if [ "$config_fixed" = true ]; then
        _message "Configuration issues were detected and fixed automatically."
        # Re-source the config file to pick up changes
        source "${oc_configFileName}"
    fi
}

# Main upgrade check and execution
main_upgrade_check() {
    # Only run if we have a config file (skip for completely new users)
    if [ -f "${oc_configFileName}" ]; then
        validate_and_fix_config
        handle_version_migration
    fi
}

# Export functions for use in other scripts
export -f prompt_ide_configuration
export -f run_upgrade_tasks
export -f handle_version_migration
export -f validate_and_fix_config
export -f main_upgrade_check
export -f version_lt
