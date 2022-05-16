#!/bin/bash
# *********************************************************************************
# (C) Copyright IBM, 2006
# All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
# *********************************************************************************

# *****************************************************************************
# Let's figure out which platform we are on and
# set up the environment for this specific configuration.
# Modifications for multiplatform support by Kevin Davis and Kevin Gilghrist
# *****************************************************************************
OSTYPE=`uname`

case $OSTYPE in
   Linux)
	CSMJDK="/opt/storage_tools/java/linux/jre_1.7.0"
	CSMCLI="/opt/storage_tools/csmcli"
	LIBDIR=${CSMCLI}/lib/
	;;
   AIX) CSMJDK="/opt/storage_tools/java/aix/jre_1.7.0"
        CSMCLI="/opt/storage_tools/csmcli"
        LIBDIR=${CSMCLI}/lib/
	;;
 SunOS) CSMJDK="/opt/storage_tools/java/solaris/jre_1.5.0"
        CSMCLI="/opt/storage_tools/csmcli"
        LIBDIR=${CSMCLI}/lib/
        ;;
   *)
	echo "Platform not supported"
	exit
	;;
esac

# *****************************************************************************
# Set up the classpath for issuing the Java(TM) command to run the CLI.
# *****************************************************************************
CSM_PATH=${LIBDIR}
CSM_PATH=${CSM_PATH}:${LIBDIR}clicommon.jar
CSM_PATH=${CSM_PATH}:${LIBDIR}csmcli.jar
CSM_PATH=${CSM_PATH}:${LIBDIR}csmclient.jar
CSM_PATH=${CSM_PATH}:${LIBDIR}jlog.jar
CSM_PATH=${CSM_PATH}:${LIBDIR}rmmessages.jar
CSM_PATH=${CSM_PATH}:${LIBDIR}ssgclihelp.jar
CSM_PATH=${CSM_PATH}:${LIBDIR}ssgfrmwk.jar
CSM_PATH=${CSM_PATH}:${LIBDIR}xerces.jar
CSM_PATH=${CSM_PATH}:${CSMCLI}

[ x"${LD_LIBRARY_PATH}" == x ] && LD_LIBRARY_PATH="$LIBDIR" || LD_LIBRARY_PATH="$LIBDIR":"${LD_LIBRARY_PATH}"; export LD_LIBRARY_PATH

# *****************************************************************************
# Execute the CSMCLI program.
# *****************************************************************************
cd "$CSMCLI"
"$CSMJDK/bin/java" -Xmx512m -classpath ${CSM_PATH} -Djava.library.path=${LIBDIR} com.ibm.storage.mdm.cli.rm.RmCli "$@"

