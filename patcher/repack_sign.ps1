# Rebuilds the decoded APK and signs it with uber-apk-signer.
# By default the debug keystore is used. A custom keystore can be supplied with
# -Keystore / -KsAlias / -KsPass / -KeyPass.

[CmdletBinding()]
param(
    [string]$UnpackedDir = '',
    [string]$OutDir = '',
    [string]$ToolsDir = '',
    [string]$ApkName = 'AngryBirdsEpic_16x9_signed.apk',
    [string]$Keystore = '',
    [string]$KsAlias = 'androiddebugkey',
    [string]$KsPass = '',
    [string]$KeyPass = '',
    [switch]$NoSign
)

. "$PSScriptRoot\common.ps1"

if ([string]::IsNullOrEmpty($UnpackedDir)) {
    $UnpackedDir = Join-Path (Get-RepoRoot) 'unpacked'
}
if ([string]::IsNullOrEmpty($OutDir)) {
    $OutDir = Join-Path (Get-RepoRoot) 'release_build'
}
if ([string]::IsNullOrEmpty($ToolsDir)) {
    $ToolsDir = Get-DefaultToolsDir
}

$apktool = Join-Path $ToolsDir 'apktool.jar'
$signer = Join-Path $ToolsDir 'uber-apk-signer.jar'
$java = Resolve-JavaExe -ToolsDir $ToolsDir

Assert-FileExists -Path $apktool -Hint 'Run .\patcher\download_tools.ps1 first.'
Assert-FileExists -Path (Join-Path $UnpackedDir 'apktool.yml') -Hint 'The unpacked directory is missing apktool.yml.'

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
$tempDir = Join-Path (Get-RepoRoot) 'temp'
New-Item -ItemType Directory -Force -Path $tempDir | Out-Null
$unsignedApk = Join-Path $tempDir 'ABE_16x9_unsigned.apk'

if (Test-Path -LiteralPath $unsignedApk) {
    Remove-Item -LiteralPath $unsignedApk -Force
}

Write-Section 'Rebuilding APK'
Write-Host "Input:  $UnpackedDir"
Write-Host "Output: $unsignedApk"

Invoke-Java -JavaExe $java -Arguments @(
    '-jar', $apktool, 'b', $UnpackedDir, '-o', $unsignedApk
)

Assert-FileExists -Path $unsignedApk

if ($NoSign) {
    $finalApk = Join-Path $OutDir $ApkName
    Copy-Item -LiteralPath $unsignedApk -Destination $finalApk -Force
    Write-Section 'Unsigned APK ready'
    Write-Host "APK: $finalApk"
    return
}

Assert-FileExists -Path $signer -Hint 'Run .\patcher\download_tools.ps1 first.'

$signOutDir = Join-Path $tempDir 'signed'
if (Test-Path -LiteralPath $signOutDir) {
    Remove-Item -LiteralPath $signOutDir -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $signOutDir | Out-Null

$signArgs = @(
    '-jar', $signer,
    '--apks', $unsignedApk,
    '--out', $signOutDir,
    '--allowResign'
)

if (-not [string]::IsNullOrEmpty($Keystore)) {
    Assert-FileExists -Path $Keystore
    $signArgs += @(
        '--ks', $Keystore,
        '--ksAlias', $KsAlias,
        '--ksPass', $KsPass,
        '--ksKeyPass', $KeyPass
    )
}

Write-Section 'Signing APK'
Invoke-Java -JavaExe $java -Arguments $signArgs

$signedApk = Get-ChildItem -LiteralPath $signOutDir -Recurse -Filter '*.apk' |
    Sort-Object LastWriteTime |
    Select-Object -Last 1
if (-not $signedApk) {
    throw "uber-apk-signer finished, but no signed APK was found in $signOutDir."
}

$finalApk = Join-Path $OutDir $ApkName
Copy-Item -LiteralPath $signedApk.FullName -Destination $finalApk -Force

$hash = (Get-FileHash -LiteralPath $finalApk -Algorithm SHA256).Hash
$size = [math]::Round((Get-Item -LiteralPath $finalApk).Length / 1MB, 1)

Write-Section 'Signed APK ready'
Write-Host "APK:    $finalApk"
Write-Host "Size:   $size MB"
Write-Host "SHA256: $hash"
Write-Host ''
Write-Host 'release_build/ is git-ignored - upload this file manually to GitHub Releases.'
