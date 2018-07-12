#!/bin/bash

start="arch.sh"
settings="settings.sh"
files=("$start" "$settings" "LICENSE")

echo "Downloading files..."
if !(wget "https://raw.githubusercontent.com/raember/bash-me/master/bashme"); then
  echo "Couldn't download file bashme/bashme." >&2
  exit 1;
fi
mv bashme bashme.sh
mkdir bashme
mv bashme.sh bashme/bashme
chmod +x "$file"
for file in "${files[@]}"; do
  if !(wget "https://raw.githubusercontent.com/raember/arch-install/master/$file"); then
    echo "Couldn't download file $file." >&2
    exit 1;
  fi
  chmod +x "$file"
done

vim "$settings"

source $start -l ./bash.log