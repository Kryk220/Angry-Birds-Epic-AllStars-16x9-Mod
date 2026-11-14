# Downloads a portable Temurin OpenJDK 17 into <ToolsDir>\jdk.
# This is optional: the patcher also works with any JDK 17+ already installed
# (JAVA_HOME or java.exe on PATH).

[CmdletBinding()]
param(
    [string]$ToolsDir = '',
    [switch]$Force
)

. "$PSScriptRoot\common.ps1"

if ([string]::IsNullOrEmpty($ToolsDir)) {
    $ToolsDir = Get-DefaultToolsDir
}

$jdkDir = Join-Path $ToolsDir 'jdk'
$javaExe = Join-Path $jdkDir 'bin\java.exe'

if ((Test-Path -LiteralPath $javaExe) -and (-not $Force)) {
    Write-Host "JDK already installed: $jdkDir"
    & $javaExe -version
    return
}

New-Item -ItemType Directory -Force -Path $ToolsDir | Out-Null

$url = 'https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.10%2B7/OpenJDK17U-jdk_x64_windows_hotspot_17.0.10_7.zip'
$zipPath = Join-Path $ToolsDir 'openjdk17.zip'
$tempDir = Join-Path $ToolsDir 'jdk_temp'

Write-Host "Downloading OpenJDK 17 from $url"
Invoke-WebRequest -Uri $url -OutFile $zipPath -UseBasicParsing

if (Test-Path -LiteralPath $tempDir) {
    Remove-Item -LiteralPath $tempDir -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $tempDir | Out-Null

Write-Host 'Extracting...'
Expand-Archive -LiteralPath $zipPath -DestinationPath $tempDir -Force

$extracted = Get-ChildItem -LiteralPath $tempDir -Directory | Select-Object -First 1
if (-not $extracted) {
    throw "The JDK archive did not contain a top-level folder."
}

if (Test-Path -LiteralPath $jdkDir) {
    Remove-Item -LiteralPath $jdkDir -Recurse -Force
}
Move-Item -LiteralPath $extracted.FullName -Destination $jdkDir

Remove-Item -LiteralPath $zipPath -Force
Remove-Item -LiteralPath $tempDir -Recurse -Force

if (-not (Test-Path -LiteralPath $javaExe)) {
    throw "JDK extraction finished, but java.exe was not found at $javaExe."
}

Write-Section 'JDK ready'
& $javaExe -version
Write-Host "Installed to: $jdkDir"
