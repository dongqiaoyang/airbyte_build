#!/bin/bash

while getopts t: flag
do
    case "${flag}" in
        t) type=${OPTARG};;
    esac
done

echo "diff_type: " ${type}
git fetch origin main
diff=$(git diff --name-only origin/main..HEAD)
DIFF_IMAGES=""
for file in $diff
do
    if [[ "${file}" =~ ^resources/"${type}"/(.+)/VERSION ]]
    then
        VERSION_FILE="${BASH_REMATCH[0]}"
        DIFF_IMAGES+="resources/${type}/${BASH_REMATCH[1]}\n"
        version=$(cat $VERSION_FILE)
        if ! [[ "$version" =~ ^([0-9]|[1-9][0-9]+)\.([0-9]|[1-9][0-9]+)\.([0-9]|[1-9][0-9]+)$ ]]
        then
            echo "$version is not in the following semantic format or the file is missing: MAJOR.MINOR.PATCH"
            exit 1
        fi
    fi
done
printf "$DIFF_IMAGES" | sort | uniq >> DIFF_IMAGES.txt

if [[ -z "$DIFF_IMAGES" ]]
then
    echo "No ${type} image versions changed."
fi

cat DIFF_IMAGES.txt