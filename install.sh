#!/bin/bash

start="arch.sh"
settings="settings.sh"
format="format.sh"
files=("$start" "$format" "$settings")

echo "Downloading files..."
mkdir bashme
if !(wget "https://github.com/raember/bash-me/blob/master/bashme" bashme/bashme); then
  echo "Couldn't download file $file"
  exit 1;
fi
chmod +x "$file"
for file in "${files[@]}"; do
  if !(wget "https://raw.githubusercontent.com/raember/arch-install/master/$file"); then
    echo "Couldn't download file $file"
    exit 1;
  fi
  chmod +x "$file"
done
source "$format"

print_prompt_boolean "Do you want to edit the ${font_code}$settings${font_no_code} file?" "y" edit
if [ "$edit" = true ] ; then
  vim "$settings"
fi

print_status "Starting script now"
source "$start"