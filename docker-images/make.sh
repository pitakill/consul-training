#!/bin/bash

# To be ran inside vagrant image
function save {
	while read -r i; do
		local id=$(echo "$i" | awk '{print $1;}')
		local repository=$(echo "$i" | awk '{print $2;}' | sed s:/:__:g)
		local tag=$(echo "$i" | awk '{print $3;}')

		local image="$repository"_"$tag".tar
		echo "Saving $id as $image"
		docker save -o "$image" "$id"
	done < <(docker images --format "{{.ID}} {{.Repository}} {{.Tag}}")
}

function load {
	while read -r i; do
		docker load -i "$i"
	done < <(ls *.tar)
}

if [[ "$1" != "" ]];then
  "$1"
else
  echo "Use this script with 'save' or 'load'"
fi

