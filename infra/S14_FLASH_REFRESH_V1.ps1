$ErrorActionPreference = 'Stop'

$KitBaseUrl = 'https://drozdov-dmitry.github.io/school14-ai-courses-site/infra'

function Download-File {
    param([string]$Url,[string]$OutFile)
    try {
        Invoke-WebRequest -Uri $Url -OutFile $OutFile -UseBasicParsing -TimeoutSec 120
        return
    } catch {
        $curl = Get-Command curl.exe -ErrorAction SilentlyContinue
        if (-not $curl) { throw }
        & curl.exe --fail --location --connect-timeout 15 --max-time 240 --output $OutFile $Url
        if ($LASTEXITCODE -ne 0) { throw ('DOWNLOAD_FAILED=' + $Url) }
    }
}

$ventoy = @(Get-Volume -ErrorAction SilentlyContinue | Where-Object { $_.FileSystemLabel -eq 'Ventoy' -and $_.DriveLetter })
if ($ventoy.Count -ne 1) { throw ('VENTOY_COUNT=' + $ventoy.Count) }

$flashRoot = "$($ventoy[0].DriveLetter):\"
$staging = Join-Path $flashRoot 'S14_AI_KIT.__new'
$active = Join-Path $flashRoot 'S14_AI_KIT'
$backupRoot = Join-Path $flashRoot 'S14_BACKUP'
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'

if (Test-Path -LiteralPath $staging) { Remove-Item -LiteralPath $staging -Recurse -Force }
New-Item -ItemType Directory -Path $staging -Force | Out-Null
New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null

$manifestPath = Join-Path $staging 'manifest.json'
$manifestShaPath = Join-Path $staging 'manifest.sha256'
Download-File "$KitBaseUrl/manifest.json" $manifestPath
Download-File "$KitBaseUrl/manifest.sha256" $manifestShaPath

$expectedManifest = ((Get-Content -LiteralPath $manifestShaPath -Raw).Trim() -split '\s+')[0].ToUpperInvariant()
$actualManifest = (Get-FileHash -LiteralPath $manifestPath -Algorithm SHA256).Hash
if ($actualManifest -ne $expectedManifest) { throw ('MANIFEST_HASH_MISMATCH=' + $actualManifest) }

$manifest = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json

foreach ($f in $manifest.files) {
    $dest = Join-Path $staging ([string]$f.path)
    $destDir = Split-Path -Parent $dest
    New-Item -ItemType Directory -Path $destDir -Force | Out-Null

    $source = [string]$f.source
    if ($source -notmatch '^https://') { $source = "$KitBaseUrl/$source" }

    Download-File $source $dest

    $actual = (Get-FileHash -LiteralPath $dest -Algorithm SHA256).Hash
    if ($actual -ne [string]$f.sha256) { throw ('FILE_HASH_MISMATCH=' + $f.path + '|' + $actual) }

    Write-Host ('VERIFIED=' + $f.path + '|SHA256=' + $actual)

    if ($f.authenticode_required -eq $true) {
        $sig = Get-AuthenticodeSignature -FilePath $dest
        Write-Host ('HIDDIFY_SIGNATURE_STATUS=' + $sig.Status)
        Write-Host ('HIDDIFY_SIGNER=' + $sig.SignerCertificate.Subject)
        if ($sig.Status -ne 'Valid') { throw ('HIDDIFY_SIGNATURE_NOT_VALID=' + $sig.Status) }
    }
}

if (Test-Path -LiteralPath $active) {
    $backup = Join-Path $backupRoot ("S14_AI_KIT_" + $stamp)
    Move-Item -LiteralPath $active -Destination $backup
    Write-Host ('BACKUP=' + $backup)
}

Move-Item -LiteralPath $staging -Destination $active

Write-Host ('FLASH=' + $flashRoot)
Write-Host ('KIT=' + $active)
Write-Host ('KIT_VERSION=' + $manifest.kit_version)
Write-Host ('MANIFEST_SHA256=' + $actualManifest)
Write-Host 'HIDDIFY_INSTALL=NOT_PERFORMED'
Write-Host 'RESULT=FLASH_REFRESHED' -ForegroundColor Green
