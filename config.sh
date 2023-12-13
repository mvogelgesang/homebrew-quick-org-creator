#!/bin/bash

cMagenta='\033[0;35m'
cNoColor='\033[0;0m'
devhub=''
folderPath=''
scratchDef=''


  echo ""
  echo "${cMagenta}What alias should be used as your default dev hub org${cNoColor}"
  read alias
  devhub=$alias

  echo ""
  echo "${cMagenta}What folder should projects be created in? (Enter full path ~/myfolder/path${cNoColor}"
  read folderPath
  folder=$folderPath

  echo ""
  echo "${cMagenta}Would you like to set a default scratch org definition file?${cNoColor}"
  select file in ..scratchDefs/*.json; do
    if [[ $REPLY == "0" ]]; then
        echo 'Exiting!' >&2
        exit
    elif [[ -z $file ]]; then
        echo 'Invalid choice, try again' >&2
    else
        scratchDef=$file
        break
    fi
done

  echo "scratchDef=$scratchDef
devHub=$devhub
folder=$folder
  " > .config


echo "Config file has been written to .config, you can update your defaults at anytime."
echo "Continuing..."