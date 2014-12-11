#!/bin/bash

if [ -n "$(df -h | grep ${dspace_install_dir})" ]
then sudo fusermount -u "${dspace_install_dir}" 
else echo "dspace já desmontado"
fi
