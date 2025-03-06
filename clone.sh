#!/bin/bash

# clones layers required to build images

clone_repo() {
    repo_url=$1
    repo_rev=$2
    repo_dir=$3

    pushd "$(pwd)"

    mkdir -p $repo_dir
    cd $repo_dir
    repo_basename=$(basename $repo_url)
    if [ ! -e "$repo_basename" ]; then
        git clone $repo_url
        cd $repo_basename
        git checkout $repo_rev
    fi

    popd
}

clone_repo https://git.yoctoproject.org/poky 7a06e2daa719ca0cac9905988f72bb0cb546c7b5 ext_layers
clone_repo https://git.yoctoproject.org/meta-arm 3cadb81ffaa9f03b92e302843cb22a9cd41df34b ext_layers
clone_repo https://github.com/linux-sunxi/meta-sunxi c73c0a2c4a91a99ea822bbc1855060fe328c310b ext_layers
