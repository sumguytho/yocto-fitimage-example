#!/bin/bash

# used to initialize bitbake environment
# this script should be sourced and not just ran
# like so: . ./source.sh
# or so: source ./source.sh

source_script=ext_layers/poky/oe-init-build-env
project_dir=$(pwd)
build_conf_dir=$project_dir/build/conf/
user_layer_templateconf=$project_dir/user_layers/meta-user/conf/templates/global

# force oe-init-build-env to update configuration from user layer
rm -f $build_conf_dir/bblayers.conf
rm -f $build_conf_dir/local.conf
rm -f $build_conf_dir/conf-notes.txt
rm -f $build_conf_dir/conf-summary.txt
rm -f $build_conf_dir/templateconf.cfg

# use user provided templateconf and set build dir to be in the project root
TEMPLATECONF=$user_layer_templateconf . $source_script $project_dir/build

cd $project_dir
unset source_script
