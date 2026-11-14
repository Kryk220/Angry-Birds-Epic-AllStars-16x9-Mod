# Decodes the original APK into a working directory with apktool.
# Tools are downloaded automatically on the first run unless -SkipTools is used.

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$ApkPath,
    [string]$OutDir = '',
    [string]$ToolsDir = '',
    [switch]$Force,
    [switch]$SkipTools
)

. "$PSScriptRoot\common.ps1"

if ([string]::IsNullOrEmpty($ToolsDir)) {
    $ToolsDir = Get-DefaultToolsDir
}
if ([string]::IsNullOrEmpty($OutDir)) {
    $OutDir = Join-Path (Get-RepoRoot) 'unpacked'
}

$apk = (Resolve-Path -LiteralPath $ApkPath).Path
Assert-FileExists -Path $apk

$apktool = Join-Path $ToolsDir 'apktool.jar'
if (-not $SkipTools -and -not (Test-Path -LiteralPath $apktool)) {
    & (Join-Path $PSScriptRoot 'download_tools.ps1') -ToolsDir $ToolsDir
}
Assert-FileExists -Path $apktool -Hint 'Run .\patcher\download_tools.ps1 first.'

if (Test-Path -LiteralPath $OutDir) {
    if (-not $Force) {
        throw "Output directory already exists: $OutDir`nUse -Force to delete and unpack again."
    }
    Remove-Item -LiteralPath $OutDir -Recurse -Force
}

$java = Resolve-JavaExe -ToolsDir $ToolsDir

Write-Section 'Unpacking APK'
Write-Host "APK:      $apk"
Write-Host "Output:   $OutDir"
Write-Host "Java:     $java"
Write-Host "apktool:  $apktool"

Invoke-Java -JavaExe $java -Arguments @(
    '-jar', $apktool, 'd', $apk, '-o', $OutDir, '-f'
)

Assert-FileExists -Path (Join-Path $OutDir 'AndroidManifest.xml') -Hint 'apktool did not produce the expected output.'
Assert-FileExists -Path (Join-Path $OutDir 'lib\arm64-v8a\libil2cpp.so') -Hint 'The APK does not contain the arm64-v8a Unity library.'

Write-Section 'Unpacked successfully'
Write-Host "Working directory: $OutDir"
Write-Host 'Next: .\patcher\apply_patch.ps1'
