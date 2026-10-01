@echo off
setlocal EnableExtensions EnableDelayedExpansion
set "S14_VERSION=S14_COURSE_EDGE_LAUNCHER_V2"
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
set "SESSIONS=%ROOT%\Sessions"
set "REPORTDIR=%USERPROFILE%\Desktop\S14_REPORTS"
if not exist "%SESSIONS%" mkdir "%SESSIONS%" >nul 2>&1
if not exist "%REPORTDIR%" mkdir "%REPORTDIR%" >nul 2>&1

rem Remove abandoned session folders older than 2 days. This never touches normal Edge profiles.
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$p='%SESSIONS%'; if(Test-Path -LiteralPath $p){Get-ChildItem -LiteralPath $p -Directory -ErrorAction SilentlyContinue | Where-Object {$_.LastWriteTime -lt (Get-Date).AddDays(-2)} | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue}" >nul 2>&1

for /f %%G in ('powershell.exe -NoProfile -Command "[guid]::NewGuid().ToString('N')"') do set "SESSION_ID=%%G"
set "SESSION=%SESSIONS%\%SESSION_ID%"
mkdir "%SESSION%" >nul 2>&1

set "REPORT=%REPORTDIR%\S14_COURSE_LAUNCH_%COMPUTERNAME%.txt"
> "%REPORT%" (
  echo Version=%S14_VERSION%
  echo Computer=%COMPUTERNAME%
  echo User=%USERNAME%
  echo Edge=%EDGE%
  echo SessionUserData=%SESSION%
  echo PrivacyMode=INPRIVATE
  echo NETWORK_MUTATION=FALSE
  echo VPN_START=FALSE
  echo CUSTOM_PROXY_CHANGE=FALSE
  echo TAB_1=%COURSE_URL%
  echo TAB_2=%DEEPSEEK_URL%
  echo TAB_3=%GITHUB_URL%
  echo TAB_4=%MAX_URL%
)

rem /wait lets us erase the disposable Edge profile immediately after the student closes the course window.
start "" /wait "%EDGE%" --inprivate --no-first-run --no-default-browser-check --user-data-dir="%SESSION%" --new-window "%COURSE_URL%" "%DEEPSEEK_URL%" "%GITHUB_URL%" "%MAX_URL%"

rmdir /s /q "%SESSION%" >nul 2>&1
>> "%REPORT%" echo SessionCleanup=REQUESTED
>> "%REPORT%" echo RESULT=COURSE_CLOSED
exit /b 0
