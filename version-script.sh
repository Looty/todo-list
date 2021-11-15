#!/bin/bash
echo "running version-script.sh from $1.."
# $1=release/1.0
version=$(echo "$1" | cut -d/ -f2)
target_branch="release/$version"
tag=""
echo "got branch: $1"
echo "got version: $version"

# 1.0, 2.4, ..
if [[ $version =~ ^[0-9].[0-9]$ ]]; then
    echo "verifying branch $target_branch.."
    branch_check=$(git rev-parse --verify "remotes/origin/$target_branch")
    git status
    echo $branch_check

    git config --global user.email "Jenkins Jenkins"
    git config --global user.name "erezmizra@gmail.com"

    if [ ! -z $branch_check ]; then
        git checkout $target_branch
        git pull
        git fetch --tags
        git tag --merged $target_branch | tail -n 1
        prevtag=$(git tag --merged $target_branch | tail -n 1)
        echo "previous tag: $prevtag"
        echo "$version exists!"
        echo "there is a x.y.z"
        major=$(echo $prevtag | cut -d. -f1)
        minor=$(echo $prevtag | cut -d. -f2)
        patch=$(echo $prevtag | cut -d. -f3)
        tag="${major}.${minor}.$(($patch+1))"
        echo "next tag: $tag"

        echo $tag > new_version.txt
    fi
fi