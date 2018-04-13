#!/bin/bash

start="arch.sh"
settings="settings.sh"
files=("$start" "arch_post.sh" "_format.sh" "$settings")
# wget() {
#     filename=$(echo "$1" | egrep -o "/[^/]+?$")
#     cp "..$filename" .
#     return;
# }
echo "Downloading files..."
for file in "${files[@]}"; do
    if !(wget "https://raw.githubusercontent.com/raember/arch-install/master/$file"); then
        echo "Couldn't download file $file"
        exit 1;
    fi
done
source _format.sh

print_prompt_boolean "Do you want to edit the ${font_code}$settings${font_no_code} file?" "y" edit "Editing settings file" "Not editing"
if [ "$edit" = true ] ; then
    vim "$settings"
fi

print_status "Starting script now"
source "$start"