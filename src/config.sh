#!/bin/bash


devhub=''
folderPath=''
scratchDef=''


  echo ""
  echo "${oc_COLOR_QUESTION}What alias should be used as your default dev hub org${oc_COLOR_NOCOLOR}"
  read alias
  devhub=$alias

  echo ""
  echo "${oc_COLOR_QUESTION}What folder should projects be created in? (Enter full path ~/myfolder/path${oc_COLOR_NOCOLOR}"
  read folderPath
  folder=$folderPath

  echo ""
  echo "${oc_COLOR_QUESTION}Would you like to set a default scratch org definition file?${oc_COLOR_NOCOLOR}"
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