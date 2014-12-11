#!/bin/bash

source mount.sh
source cwebapps.sh

${tomcat_restart_command}
${tomcat_view_catalina_out}
