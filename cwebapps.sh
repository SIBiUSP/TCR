#!/bin/bash

if [ -d "${tomcat_context_dir}" ]
then if [ -d "${dspace_install_dir}/webapps" ]
     then pushd "${dspace_install_dir}/webapps"
          for w in *
          do if [ "$w" = "${dspace_ui}" ]
            then echo "<Context docBase=\"${dspace_install_dir}/webapps/$w\"/>" > "${tomcat_context_dir}/ROOT.xml"
            else echo "<Context docBase=\"${dspace_install_dir}/webapps/$w\"/>" > "${tomcat_context_dir}/$w.xml"
            fi
          done
	  popd
     else echo "no dspace_install_dir/webapps"
     fi
else echo "no tomcat_context_dir"
fi

