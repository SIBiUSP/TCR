#!/bin/bash

aki=$(dirname $(readlink -e $0));
dspace_desenv_dir="${aki}/dspace"

if [ -z "$(df -h | grep ${dst})" ]
then sudo mhddfs ${dspace_desenv_dir},${dspace_dat_dir},${dspace_pre_dir} ${dspace_install_dir} -o ro,allow_other
else echo "dspace já montado"
fi
