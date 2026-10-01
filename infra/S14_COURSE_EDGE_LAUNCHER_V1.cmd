@echo off
setlocal EnableExtensions
set "S14_VERSION=S14_COURSE_EDGE_LAUNCHER_V1"
set "COURSE_URL=https://drozdov-dmitry.github.io/school14-ai-courses-site/block-01/"
set "DEEPSEEK_URL=https://chat.deepseek.com/"
set "GITHUB_URL=https://github.com/"
set "MAX_URL=https://web.max.ru/"

if /I "%COMPUTERNAME%"=="MATAMASAKI" (
  echo STOP: PERSONAL_LAPTOP_MATAMASAKI
  exit /b 20
)

set "EDGE="
if exist "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" set "EDGE=C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
if not defined EDGE if exist "C:\Program Files\Microsoft\Edge\Application\msedge.exe" set "EDGE=C:\Program Files\Microsoft\Edge\Application\msedge.exe"

if not defined EDGE (
  echo STOP: EDGE_NOT_FOUND
  exit /b 21
)

set "ROOT=%LOCALAPPDATA%\S14Course"
set "PROFILE=%ROOT%\EdgeUserData"
set "REPORTDIR=%USERPROFILE%\Desktop\S14_REPORTS"
if not exist "%PROFILE%" mkdir "%PROFILE%" >nul 2>&1
if not exist "%REPORTDIR%" mkdir "%REPORTDIR%" >nul 2>&1

for /f "tokens=1-4 delims=/:. " %%a in ("%date% %time%") do set "STAMP=%%d%%b%%c-%%a"
set "REPORT=%REPORTDIR%\S14_COURSE_LAUNCH_%COMPUTERNAME%.txt"

> "%REPORT%" (
  echo Version=%S14_VERSION%
  echo Computer=%COMPUTERNAME%
  echo User=%USERNAME%
  echo Edge=%EDGE%
  echo EdgeUserData=%PROFILE%
  echo NETWORK_MUTATION=FALSE
  echo VPN_START=FALSE
  echo CUSTOM_PROXY_CHANGE=FALSE
  echo TAB_1=%COURSE_URL%
  echo TAB_2=%DEEPSEEK_URL%
  echo TAB_3=%GITHUB_URL%
  echo TAB_4=%MAX_URL%
)

start "" "%EDGE%" --no-first-run --no-default-browser-check --user-data-dir="%PROFILE%" --new-window "%COURSE_URL%" "%DEEPSEEK_URL%" "%GITHUB_URL%" "%MAX_URL%"

>> "%REPORT%" echo RESULT=LAUNCH_REQUESTED
exit /b 0
