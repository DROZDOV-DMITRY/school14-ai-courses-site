@echo off
setlocal
set "TARGET=%~d0\S14\S14_APPLY_UPDATE_V2.cmd"
if not exist "%TARGET%" (
  echo S14 kit not found: %TARGET%
  pause
  exit /b 2
)
call "%TARGET%"
exit /b %ERRORLEVEL%
