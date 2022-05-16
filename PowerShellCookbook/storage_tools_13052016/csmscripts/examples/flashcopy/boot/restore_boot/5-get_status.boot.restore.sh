#!/bin/bash

# Figure out our directory path
if [[ ${0} == '/'* ]]; then 
	ScriptLocation="`dirname $0`" 
else 
	ScriptLocation="`pwd`"/"`dirname $0`" 
fi 

# Determine action from the script name
Action=`basename ${0} | awk -F- {'print $2'} | awk -F. {'print $1'}`

# Replace + char with : char to avoid filename problems
Action=`echo ${Action} | sed s/+/:/`

# Set environment vars.  
working_directory=/opt/storage_tools/csmscripts/cli_script
tpcr_client=/opt/storage_tools/csmcli/csmcli.sh

# Make sure we are in the working directory for the tpc-r script
cd ${working_directory}

# Launch tpc-r script to perform action
./tpcr_action.pl --action=${Action}  -session FCBootRestore
