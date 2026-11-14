# One-command build: unpack -> patch -> rebuild -> sign.
#
# Example:
#   .\patcher\build.ps1 -ApkPath "C:\Downloads\All Stars 1.2.8.1.apk"
#
# The final APK is written to release_build\AngryBirdsEpic_16x9_signed.apk.

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$ApkPath,
    [string]$ToolsDir = '',
    [string]$OutDir = '',
    [string]$ApkName = 'AngryBirdsEpic_16x9_signed.apk',
    [switch]$SkipTools,
    [switch]$SkipManifest,
    [switch]$NoSign
)

. "$PSScriptRoot\common.ps1"

if ([string]::IsNullOrEmpty($ToolsDir)) {
    $ToolsDir = Get-DefaultToolsDir
}
if ([string]::IsNullOrEmpty($OutDir)) {
    $OutDir = Join-Path (Get-RepoRoot) 'release_build'
}

$apk = (Resolve-Path -LiteralPath $ApkPath).Path
$apktool = Join-Path $ToolsDir 'apktool.jar'
$signer = Join-Path $ToolsDir 'uber-apk-signer.jar'

if (-not $SkipTools) {
    if (-not (Test-Path -LiteralPath $apktool) -or (-not (Test-Path -LiteralPath $signer))) {
        & (Join-Path $PSScriptRoot 'download_tools.ps1') -ToolsDir $ToolsDir
    }
}

& (Join-Path $PSScriptRoot 'unpack_and_setup.ps1') `
    -ApkPath $apk `
    -OutDir (Join-Path (Get-RepoRoot) 'unpacked') `
    -ToolsDir $ToolsDir `
    -Force `
    -SkipTools

& (Join-Path $PSScriptRoot 'apply_patch.ps1') `
    -UnpackedDir (Join-Path (Get-RepoRoot) 'unpacked') `
    -SkipManifest:$SkipManifest

& (Join-Path $PSScriptRoot 'repack_sign.ps1') `
    -UnpackedDir (Join-Path (Get-RepoRoot) 'unpacked') `
    -OutDir $OutDir `
    -ToolsDir $ToolsDir `
    -ApkName $ApkName `
    -NoSign:$NoSign

Write-Section 'Build complete'
Write-Host "APK: $(Join-Path $OutDir $ApkName)"
