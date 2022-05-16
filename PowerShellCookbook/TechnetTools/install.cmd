echo "Installing modules from %~dp0"
xcopy "%~dp0AutoBrowse" "%userprofile%\Documents\WindowsPowerShell\Modules\AutoBrowse" /y /s /i /d 

xcopy "%~dp0Pipeworks" "%userprofile%\Documents\WindowsPowerShell\Modules\Pipeworks" /y /s /i /d 

xcopy "%~dp0TechnetTools" "%userprofile%\Documents\WindowsPowerShell\Modules\TechnetTools" /y /s /i /d 

