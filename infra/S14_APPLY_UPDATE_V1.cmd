@echo off
setlocal
set "S14_SELF=%~f0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$p=$env:S14_SELF;$raw=[IO.File]::ReadAllText($p,[Text.Encoding]::UTF8);$m='###S14_POWERSHELL_PAYLOAD###';$i=$raw.LastIndexOf($m);if($i -lt 0){throw 'PAYLOAD_NOT_FOUND'};$code=$raw.Substring($i+$m.Length);$tmp=Join-Path $env:TEMP ('S14_APPLY_'+[guid]::NewGuid().ToString('N')+'.ps1');[IO.File]::WriteAllText($tmp,$code,(New-Object Text.UTF8Encoding($true)));try{& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $tmp;exit $LASTEXITCODE}finally{Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue}"
set "RC=%ERRORLEVEL%"
echo.
if "%RC%"=="0" (echo UPDATE APPLIED) else (echo UPDATE FAILED. Code=%RC%)
pause
endlocal & exit /b %RC%
###S14_POWERSHELL_PAYLOAD###
$ErrorActionPreference = 'Stop'

if ($env:COMPUTERNAME -eq 'MATAMASAKI') {
    throw 'PERSONAL_LAPTOP_MATAMASAKI'
}

$kitRoot = Split-Path -Parent $env:S14_SELF
$manifestPath = Join-Path $kitRoot 'manifest.json'
if (-not (Test-Path -LiteralPath $manifestPath)) {
    throw 'MANIFEST_NOT_FOUND'
}

$manifest = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
$localRoot = Join-Path $env:LOCALAPPDATA 'S14Course'
$reportDir = Join-Path ([Environment]::GetFolderPath('Desktop')) 'S14_REPORTS'
New-Item -ItemType Directory -Path $localRoot -Force | Out-Null
New-Item -ItemType Directory -Path $reportDir -Force | Out-Null

$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$report = Join-Path $reportDir ("S14_APPLY_UPDATE_{0}_{1}.txt" -f $env:COMPUTERNAME,$stamp)

function Line([string]$s) { $s | Tee-Object -FilePath $report -Append }

$proxyBefore = Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -ErrorAction SilentlyContinue
Line ('Version=S14_APPLY_UPDATE_V1')
Line ('KitVersion=' + $manifest.kit_version)
Line ('Computer=' + $env:COMPUTERNAME)
Line ('User=' + $env:USERNAME)
Line ('ProxyBefore=' + $proxyBefore.ProxyEnable + '|' + $proxyBefore.ProxyServer)
Line 'NETWORK_MUTATION=FALSE'
Line 'VPN_START=FALSE'
Line 'HIDDIFY_INSTALL=NOT_PERFORMED'

foreach ($f in $manifest.files) {
    if (-not $f.target) { continue }

    $src = Join-Path $kitRoot ([string]$f.path)
    if (-not (Test-Path -LiteralPath $src)) { throw ('SOURCE_MISSING=' + $f.path) }

    $srcHash = (Get-FileHash -LiteralPath $src -Algorithm SHA256).Hash
    if ($srcHash -ne [string]$f.sha256) { throw ('SOURCE_HASH_MISMATCH=' + $f.path) }

    $dst = [Environment]::ExpandEnvironmentVariables([string]$f.target)
    $dstDir = Split-Path -Parent $dst
    New-Item -ItemType Directory -Path $dstDir -Force | Out-Null
    Copy-Item -LiteralPath $src -Destination $dst -Force

    $dstHash = (Get-FileHash -LiteralPath $dst -Algorithm SHA256).Hash
    if ($dstHash -ne [string]$f.sha256) { throw ('TARGET_HASH_MISMATCH=' + $dst) }
    Line ('COPIED=' + $dst + '|SHA256=' + $dstHash)
}

$launcher = Join-Path $localRoot 'bin\S14_COURSE_EDGE_LAUNCHER_V1.cmd'
if (-not (Test-Path -LiteralPath $launcher)) { throw 'LOCAL_LAUNCHER_MISSING' }

$desktop = [Environment]::GetFolderPath('Desktop')
$shortcutPath = Join-Path $desktop 'КУРС ИИ.lnk'
$ws = New-Object -ComObject WScript.Shell
$sc = $ws.CreateShortcut($shortcutPath)
$sc.TargetPath = $launcher
$sc.WorkingDirectory = (Split-Path -Parent $launcher)
$sc.Description = 'КУРС ИИ — отдельный Edge профиль'
$sc.Save()

$proxyAfter = Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -ErrorAction SilentlyContinue
Line ('ProxyAfter=' + $proxyAfter.ProxyEnable + '|' + $proxyAfter.ProxyServer)

if ($proxyBefore.ProxyEnable -ne $proxyAfter.ProxyEnable -or [string]$proxyBefore.ProxyServer -ne [string]$proxyAfter.ProxyServer) {
    Line 'RESULT=FAIL_PROXY_CHANGED_EXTERNALLY'
    throw 'PROXY_CHANGED_DURING_UPDATE'
}

Line ('Shortcut=' + $shortcutPath)
Line 'RESULT=UPDATE_APPLIED'
explorer.exe /select,"$report"
