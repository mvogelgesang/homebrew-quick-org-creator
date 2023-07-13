alias=""
datedAlias=$(date '+%Y%m%d')_
scratchDef="utilities/..scratchDefs/default.json"
devHub="pboDevHub"
folder="pboDevHub"

echo "This script will create a new scratch org off of $devHub. Checking pre-conditions..."

if ! command -v code
then
  echo ">> VSCode `code` terminal command not found, you will have to launch your editor manually."
  echo ">> To add `code` as a terminal command, open VSCode, press CMD+Shift+P, select Install 'code' command in PATH"
  echo ">> If that does not work, see https://github.com/microsoft/vscode/issues/154163"
fi

echo ""
echo "What is the alias for the org? This might be a Org62 case number (37711301-pushUpgrades), trailhead exercise, etc."
read alias
datedAlias+=$alias

echo "Scratch Definition (leave blank for default $scratchDef)"
read s
if [ ! -z "$s" ]
  then
    scratchDef=$s
fi

echo "What folder should this go in? (Leave blank for default $folder)"
read f
if [ ! -z "$f" ]
  then
    folder=$f
fi

# echo "Devhub: $devHub"
# echo "scratchDef: $scratchDef"
# echo "alias: $alias"

sf org create scratch -f $scratchDef -a $alias -v $devHub -w 10 -y 21
sf config set target-org=$alias
sf project generate -t standard -n $datedAlias -d $folder
code $folder/$datedAlias
cd $folder/$datedAlias
echo "Installing dependencies"
npm i
echo "Opening the new org"
sf org open -o $alias
echo "You will need to authenticate your new org"