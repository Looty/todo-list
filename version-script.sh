#!/bin/bash
echo "running version-script.sh from main.."
version="$1"
origin_branch="$2"
echo "manual version: $version"
echo "gitlabTargetBranch: $origin_branch"

# if pushed from release/{x.y} && entered version manually
if [[ $origin_branch =~ ^release/[0-9].[0-9]$ ]] || [ $version != "main" ]; then

    git branch -av
    if [[ $origin_branch =~ ^release/[0-9].[0-9]$ ]]; then
        target_branch=$origin_branch
    else
        target_branch="release/$version"
    fi
    
    echo "verifying branch $target_branch.."
    branch_check=$(git rev-parse --verify "remotes/origin/$target_branch")
    ls -alF
    echo $branch_check

    git config --global user.email "Jenkins Jenkins"
    git config --global user.name "erezmizra@gmail.com"

    if [ ! -z $branch_check ]; then
        if [[ $origin_branch =~ ^release/[0-9].[0-9]$ ]]; then
            tag=
            echo "$version exists!"
            git checkout "$target_branch"
            ver=`sed -n '2p' ./v.txt | cut -c4`

            if [ ! -z "$ver" ]; then
                # there is a x.x.x
                echo "there is a x.x.x"
                major=`sed -n '2p' ./v.txt | cut -c1`
                minor=`sed -n '2p' ./v.txt | cut -c3`
                patch=`sed -n '2p' ./v.txt | cut -c5`
                tag="${major}.${minor}.$(($patch+1))"
                sed -i ./v.txt -e '$ d'
                echo $tag >> v.txt
                # to be continued in test-script.sh
            else 
                # there is a x.x
                echo "there is a x.x"
                major=`sed -n '2p' ./v.txt | cut -c1`
                minor=`sed -n '2p' ./v.txt | cut -c3`
                tag="${major}.${minor}.1"
                sed -i ./v.txt -e '$ d'
                echo $tag >> v.txt
                # to be continued in test-script.sh
            fi
        fi
    else
        echo "$version does not exist! ://"
        git checkout -b $target_branch main
        echo -e "\n$version" >> ./v.txt
        git commit -am "updated ver text $version, creating new branch"
        git push --set-upstream origin $target_branch
    fi
fi