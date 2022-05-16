@echo off
TITLE IBM Replication Manager CLI
@setlocal

REM ***************************************************************************
REM Set up the environment for this specific configuration.  Both
REM JAVA_HOME and CSMCLI_HOME must be defined in environment variables.
REM Modifications for Ford OLA2 script by Kevin Davis
REM ***************************************************************************
set CSMJDK=..\java\windows\jre_1.7.0\
if "%CSMJDK%"=="" GOTO ERROR_JAVA
set CSMCLI=c:\storage_tools\csmcli
if "%CSMCLI%"=="" GOTO ERROR_CLI
set PATH=%CSMCLI%\lib;%PATH%
set CSMCP=.;lib\csmcli.jar;lib\clicommon.jar;lib\csmclient.jar;lib\essClientApi.jar;
set CSMCP=%CSMCP%;lib\ibmCIMClient.jar;lib\jlog.jar;lib\jsse.jar;lib\xerces.jar;lib\JSON4J.jar;
set CSMCP=%CSMCP%;lib\rmmessages.jar;lib\snmp.jar;lib\ssgclihelp.jar;lib\ssgfrmwk.jar;
set JAVA_ARGS=
cd /d "%CSMCLI%"

REM ***************************************************************************
REM Find the current code page
REM ***************************************************************************

chcp > %TEMP%\chcp.txt
"%CSMJDK%\bin\java" -classpath %CSMCP% com.ibm.storage.mdm.cli.rm.CodePageExtractor "%TEMP%\chcp.txt" "%TEMP%\codepage.txt"
SET /P CODEPAGEVALUE= < %TEMP%\codePage.txt
if "%CODEPAGEVALUE%"=="" GOTO RUNPROG
SET JAVA_ARGS=%JAVA_ARGS% -Dfile.encoding=%CODEPAGEVALUE%

REM ***************************************************************************
REM Execute the CSMCLI program.
REM ***************************************************************************
:RUNPROG
"%CSMJDK%\bin\java" %JAVA_ARGS% -Xmx512m -Djava.net.preferIPv4Stack=false -classpath %CSMCP% com.ibm.storage.mdm.cli.rm.RmCli %*
GOTO END

REM ***************************************************************************
REM The Java interpreter home environment variable, JAVA_HOME, is not set
REM ***************************************************************************
:ERROR_JAVA
echo The JAVA_HOME environment variable is not set.  Please see documentation.
GOTO END

REM ***************************************************************************
REM The CSM CLI home environment variable, CSMCLI_HOME, is not set
REM ***************************************************************************
:ERROR_CLI
echo The CSMCLI_HOME environment variable is not set.  Please see documentation.

:END
if not %ERRORLEVEL% == 0 pause
@endlocal
