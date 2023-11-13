@echo off

copy /y kubectl.exe "%windir%\system32"
copy /y xkube.cmd "%windir%\system32"

if not exist "%userprofile%\.kube" md "%userprofile%\.kube"
copy /y ..\config "%userprofile%\.kube"

echo install success
echo.
pause