
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
    # If it's an array, convert it to a string
    local var_value_string="($(IFS=" "; echo "${var_value[*]}"))"
  fi

  if grep -q "${var_name}=" "$config_file"; then
    # If it exists, replace it (using # as a sed delimiter rather than the traditional /)
    sed -i "" "s#$var_name=.*#$var_name=$var_value_string#" "$config_file"
  else
    # If it doesn't exist, add it
    echo -e "\nexport $var_name=$var_value_string" >> "$config_file"
  fi

}