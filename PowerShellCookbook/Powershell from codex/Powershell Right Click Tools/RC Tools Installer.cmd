@echo off
@setlocal enableextensions
@cd /d "%~dp0"

set arg1=%1

if [%1] == [/s] goto silent

wscript.exe "SCCMConsoleExtensions\SilentOpenPS.vbs" "SCCMConsoleExtensions\Tools Installer.ps1"

Goto end

:silent

set menupath=%SMS_Admin_UI_Path1%
set menupath=%menupath:~0,-8%
if exist "%menupath%" goto FoundMenu


FOR /F "tokens=2*" %%I IN ('reg query  HKEY_Local_Machine\Software\Wow6432Node\Microsoft\ConfigMgr10\AdminUI /v AdminUILog') DO @SET MenuPath=%%J
set menupath=%menupath:~0,-11%
if exist "%menupath%" goto FoundMenu

FOR /F "tokens=2*" %%I IN ('reg query  HKEY_Local_Machine\Software\Microsoft\ConfigMgr10\AdminUI /v AdminUILog') DO @SET MenuPath=%%J
set menupath=%menupath:~0,-11%
if exist "%menupath%" goto FoundMenu

Goto NotFound

:FoundMenu
set menupath=%menupath%XmlStorage\Extensions\

xcopy SCCMConsoleExtensions "C:\Program Files\SCCMConsoleExtensions\" /e /y
xcopy Extensions "%menupath%" /y /e
del /f "%menupath%Actions\3fd01cd1-9e01-461e-92cd-94866b8d1f39\Right Click Tools - Console Tools.xml"
del /f "%menupath%Actions\3fd01cd1-9e01-461e-92cd-94866b8d1f39\Right Click Tools - Client Actions.xml"
del /f "%menupath%Actions\3fd01cd1-9e01-461e-92cd-94866b8d1f39\Right Click Tools - Client Tools.xml"
del /f "%menupath%Actions\ed9dee86-eadd-4ac8-82a1-7234a4646e62\Right Click Tools - Console Tools.xml"
del /f "%menupath%Actions\ed9dee86-eadd-4ac8-82a1-7234a4646e62\Right Click Tools - Client Actions.xml"
del /f "%menupath%Actions\ed9dee86-eadd-4ac8-82a1-7234a4646e62\Right Click Tools - Client Tools.xml"
del /f "%menupath%Actions\3785759b-db2c-414e-a540-e879497c6f97\SCCM-Client Actions(Collection).xml"
del /f "%menupath%Actions\3785759b-db2c-414e-a540-e879497c6f97\SCCM-Client Tools(Collection).xml"
del /f "%menupath%Actions\3785759b-db2c-414e-a540-e879497c6f97\SCCM-Console Tools(Collection).xml"
del /f "%menupath%Actions\a92615d6-9df3-49ba-a8c9-6ecb0e8b956b\SCCM-Client Actions(Collection).xml"
del /f "%menupath%Actions\a92615d6-9df3-49ba-a8c9-6ecb0e8b956b\SCCM-Client Tools(Collection).xml"
del /f "%menupath%Actions\a92615d6-9df3-49ba-a8c9-6ecb0e8b956b\SCCM-Console Tools(Collection).xml"
del /f "%menupath%Actions\0770186d-ea57-4276-a46b-7344ae081b58\Right Click Tools - Console Tools.xml"
del /f "%menupath%Actions\0770186d-ea57-4276-a46b-7344ae081b58\Right Click Tools - Client Actions.xml"
del /f "%menupath%Actions\0770186d-ea57-4276-a46b-7344ae081b58\Right Click Tools - Client Tools.xml"

cls

net session >nul 2>&1
if %errorLevel% == 0 (
goto HasAdmin
) else (
echo No admin permissions detected. Tools might not be correctly installed.
echo Please re-run silent install from an elevated command prompt to ensure
echo the tools are installed correctly.
)
pause
pause
goto end

:HasAdmin
cls
Echo Files copied!  Close and reopen the ConfigMgr 2012 console.
Echo If you don't see the tools, make sure the Extensions folder is in:
Echo \Microsoft Configuration Manager\AdminConsole\XmlStorage\
echo.
pause

Goto End

:NotFound

cls
echo Could not find the installed console. If you just installed, please
echo restart the computer and run again.

pause

:end