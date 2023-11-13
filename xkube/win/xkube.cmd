@echo off
rem =================================================
rem    System Required: Microsoft Windows 7+
rem    Description: K8s工具
rem    Version: 1.0.3
rem    Author: jinxiao.wu
rem    Date: 2023-09-05
rem    E-mail: wujx5251@163.com
rem =================================================

title xkube client
setlocal enabledelayedexpansion
chcp 65001>nul

set ns=dev
set "log="
set "con="
set "inf="
set "re="
set "pod="
set "args="
set "ctx="
set "kw="
set "all="
set "cls="
call:options %*

if not "%ctx%"=="" ( 
  call kubectl config use-context %ctx%
) else if not "%cls%"=="" (
  call:claster
  exit /b
)

if errorlevel 1 (
  exit /b
)

for /f "tokens=1*" %%a in ('kubectl config view -o jsonpath^="{.current-context}"') do (
  set ctx=%%a
)

call:get_pods 1
exit /b


:usage
echo Usage: [KEYWORD] [-n NAMESPACE] [-a ALL] [-c CONTEXT] [-l CLUSTER] [-h^|--help]
echo where COMMAND is one of: [-n^|-c^|-l^|-h]
echo         -n    命名空间
echo         -c    配置切换
echo         -a    全部Pod
echo         -l    配置列表
echo -h^|--help    帮助
echo    keyword    pod关键字
goto:eof


:help
echo Usage: ID [KEYWORD] [-c CONTAINER] [-l LOGS] [-i INFO] [-r RESTART] [-h HELP]
echo where COMMAND is one of: [id -l^|-c^|-i^|-r] [-n namespace] [q^|r^|h]
echo   id -l    容器日志
echo   id -i    Pod信息
echo   id -r    Pod重启
echo   id -c    指定进入Pod容器名称
echo      -n    命名空间
echo       h    帮助
echo       r    重置Pod列表
echo       q    退出

echo  keyword    pod关键字
echo.
goto:eof


:options
:loopo
if "%1"=="" (
  goto:eof
) else if "%1"=="-n" (
  set ns=%2
  shift
) else if "%1"=="-c" (
  set ctx=%2
  shift
) else if "%1"=="-l" (
  set cls=1
) else if "%1"=="-a" (
  set all=1
) else if "%1"=="-h" (
  call:usage
  exit /b 1
) else if "%1"=="--help" (
  call:usage
  exit /b 1
) else (
  set kw=%1
)
shift
goto:loopo


:args
:loopa
if "%1"=="" (
  goto:eof
) else if "%1"=="-c" (
  set con=%2
  shift
) else if "%1"=="-n" (
  set ns=%2
  shift
) else if "%1"=="-l" (
  set log=1
) else if "%1"=="-i" (
  set inf=1
) else if "%1"=="-r" (
  set re=1
) else (
  set pod=%1
)
shift
goto:loopa


:attach
set "log="
set "con="
set "inf="
set "re="
set "pod="
set "args="
echo [32mPlease enter Id entry or keyword search, help enter [h] or exit enter [q][0m
echo context：%ctx%，namespace：%ns%
if not "%kw%"=="" (
  echo keyword：%kw%
)

set /p "args=xkube>"
set idx=0
for %%a in (%args%) do (
  set /a idx+=1
)

if !idx! gtr 1 (
  call:args %args%
  call:execute
) else if "%args%"=="q" (
  echo bye
  exit /b
) else if "%args%"=="r" (
  set "kw="
  call:get_pods
) else if "%args%"=="h" (
  call:help
  goto:attach
) else (
  if not "%args%"=="" (
    set /a idx="%args%"
    if !idx! gtr 0 if !idx! leq %cnt% (
      set /a idx=!idx!-1
      call:signin !idx!
      echo.
      goto:attach
      exit \b
    )
    set kw=%args%
    call:get_pods
  ) else (
    call:get_pods
  )
)
goto:eof


:get_pods
set "cmd=kubectl get pods -n %ns%"
if "%all%"=="" (
  set "cmd=%cmd% --show-labels^|findstr /i /v "statefulset.kubernetes.io/pod-name""
)
if not "%kw%"=="" (
  set "cmd=%cmd%^|findstr /i "%kw%""
)
call:format -50 Name
set name=%format% 
call:format -20 Status
echo [32m Id %name%%format% Age[0m
set /a cnt=0
set /a ecnt=0
for /f "tokens=1,3,5,7 delims= " %%a in ('%cmd%') do (
  if not "%%a"=="NAME" (	
    if "%%b" == "Running" (
      set pods[!cnt!]=%%a
      set /a cnt+=1
      call:format 3 !cnt!
      set idx=!format!
      call:format -50 %%a
      set name=!format!
      call:format -20 %%b
      set age=%%c
      if not "%%d"=="" (
        set age=%%d
      )

      echo [32m!idx![0m[36m !name! !format! !age![0m
      rem set "info=!info![32m!idx![0m  [36m!format! %%b[0m&echo."
    ) else (
      set /a ecnt+=1
      set errs[!ecnt!].name=%%a
      set errs[!ecnt!].state=%%b
      set errs[!ecnt!].age=%%c
      if not "%%d"=="" (
        set errs[!ecnt!].age=%%d
      )
      rem set "info=!info![31m!idx! !format! %%b[0m&echo."
      rem echo [31m!idx! !format! %%b[0m
    )
  )
)

for /l %%i in (1,1,!ecnt!) do (
  set pods[!cnt!]=!errs[%%i].name!
  set /a cnt+=1
  call:format 3 !cnt!
  set idx=!format!
  call:format -50 !errs[%%i].name!
  set name=!format!
  call:format -20 !errs[%%i].state!
  echo [31m!idx! !name! !format! !errs[%%i].age![0m
)
echo.

call:attach
goto:eof


:execute
set "tk=%pod%"
if not "%pod%"=="" (
  set /a pod=%pod%
) else (
  set /a pod=0
)
if %pod% gtr 0 if %pod% leq %cnt% (
  set /a idx=%pod%-1
  if not "%log%"=="" (
    call:logs !idx!
  ) else if not "%re%"=="" (
    call:redeploy !idx!
  ) else if not "%inf%"=="" (
    call:info !idx!
  ) else (
    call:signin !idx!
  )
  echo.
  call:attach
  exit /b 
)
set "kw=%tk%"
call:get_pods
goto:eof


:info
call kubectl get pod !pods[%1]! -n %ns% -o jsonpath="containers:{'\t'}{range .status.containerStatuses[*]}[{.name}]:{.started} {end}{'\n'}name:{'\t'}{'\t'}{.metadata.name}{'\n'}ip:{'\t'}{'\t'}{.status.podIP}{'\n'}pod state:{'\t'}{.status.phase}{'\n'}namespace:{'\t'}{.metadata.namespace}{'\n'}start time:{'\t'}{.status.startTime}{'\n'}"
goto:eof

:logs
if not "%con%"=="" (
  call kubectl logs !pods[%1]! -c %con% -n %ns%
) else (
  call kubectl logs !pods[%1]! -n %ns%
)
goto:eof


:signin
if not "%con%"=="" (
  call kubectl exec -it !pods[%1]! -c %con% -n %ns% /bin/sh --login
) else (
  call kubectl exec -it !pods[%1]! -n %ns% -- /bin/sh --login
)
goto:eof


:replace
for /f "tokens=1*" %%a in ('kubectl get pods -n %ns% -o jsonpath^="{.items[?(@.metadata.labels.app=='%2')].metadata.name}"') do (
  set pods[%1]=%%a
)
goto:eof

:redeploy
set "lab="
for /f "tokens=1* delims=," %%a in ('kubectl get pod !pods[%1]! -n %ns% -o jsonpath^="{.metadata.labels.app},{.metadata.ownerReferences[0].kind}"') do (
  if "%%b"=="StatefulSet" (
    call kubectl rollout restart statefulset %%a -n %ns%
  ) else if "%%b"=="DaemonSet" (
    call kubectl rollout restart daemonset %%a -n %ns%
  ) else (
    call kubectl rollout restart deployment %%a -n %ns%
  )
  set lab=%%a
)

for /l %%i in (1,1,300) do (
  call:state %1  
  if errorlevel 1 (
    echo|set /p="." 
    timeout /nobreak /t 1 >nul
  ) else (
    call:replace %1 !lab!
    if %%i gtr 0 (
      echo.
    )
    echo [32mrestart success[0m
    exit /b  
  )
)
echo.
echo [31mrestart fail[0m
goto:eof


:state
for /f "tokens=3 delims= " %%a in ('kubectl get pods -n %ns%^|findstr /i "!pods[%1]!"') do (
  if "%%a"=="Running" (
    exit /b 1
  ) else if "%%a"=="Terminating" (
    exit /b 2
  ) else if "%%a"=="Pending" (
    exit /b 2
  ) else (
    exit /b 0
  )
)
goto:eof

:claster
for /f "tokens=1* delims= " %%a in ('kubectl config view -o jsonpath^="{.current-context} {.contexts[*].name}"') do (
  for %%i in (%%b) do (
    if "%%i"=="%%a" (
      echo %%i[32m        activate[0m 
    ) else (
      echo %%i
    )
  )
)
goto:eof


:format
set format=%2
set mlen=%1
if %1 lss 0 ( 
  set /a mlen=%1*-1 
)
set l=!lens[%2]!
if "%l%"=="" (
  call:len %2 %mlen%
  set l=!len!
  set lens[%2]=!l!
)

if !l! lss %mlen% (
  set /a l=mlen-l
  call:space !l!
  if %1 lss 0 (
    set "format=%format%!space!"
  ) else (
    set "format=!space!%format%"
  )
)
goto:eof


:len
set str=%1
set min=0
set max=%2
:loopl
set /a "len=min+(max-min)/2"
if %len%==%min% (
  set /a len+=1
  goto:eof
)
if "!str:~%len%!"=="" (set /a max=len) else set /a min=len
goto:loopl


:space
set "space=                                                                                                                                                                                                                                                                                                            "
set space=!space:~0,%1!
goto:eof