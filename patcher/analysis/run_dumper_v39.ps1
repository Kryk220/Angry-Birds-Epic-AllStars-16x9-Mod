# Same as run_dumper.ps1, but uses the c01ns fork with metadata v39 support
# (needed for newer Unity builds). Optional helper - not needed to build the mod.

[CmdletBinding()]
param(
    [string]$ToolsDir = '',
    [string]$UnpackedDir = '',
    [string]$OutDir = '',
    [switch]$Force
)

. "$PSScriptRoot\..\common.ps1"

if ([string]::IsNullOrEmpty($ToolsDir)) {
    $ToolsDir = Get-DefaultToolsDir
}
if ([string]::IsNullOrEmpty($UnpackedDir)) {
    $UnpackedDir = Join-Path (Get-RepoRoot) 'unpacked'
}
if ([string]::IsNullOrEmpty($OutDir)) {
    $OutDir = Join-Path (Get-RepoRoot) 'il2cpp_dump'
}

$dumperDir = Join-Path $ToolsDir 'Il2CppDumper'
New-Item -ItemType Directory -Force -Path $dumperDir | Out-Null
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

$exe = Get-ChildItem -LiteralPath $dumperDir -Recurse -Filter 'Il2CppDumper.exe' -ErrorAction SilentlyContinue |
    Select-Object -First 1

if (-not $exe -or $Force) {
    if ($Force -and (Test-Path -LiteralPath $dumperDir)) {
        Remove-Item -LiteralPath $dumperDir -Recurse -Force
    }
    New-Item -ItemType Directory -Force -Path $dumperDir | Out-Null

    $url = 'https://github.com/c01ns/Il2CppDumper/releases/download/v39.1/Il2CppDumper-win-x64-net8-v39.1.zip'
    $zipPath = Join-Path $ToolsDir 'Il2CppDumper_v39.zip'
    Write-Host "Downloading $url"
    Invoke-WebRequest -Uri $url -OutFile $zipPath -UseBasicParsing
    Expand-Archive -LiteralPath $zipPath -DestinationPath $dumperDir -Force
    Remove-Item -LiteralPath $zipPath -Force

    $exe = Get-ChildItem -LiteralPath $dumperDir -Recurse -Filter 'Il2CppDumper.exe' |
        Select-Object -First 1
}

if (-not $exe) {
    throw 'Il2CppDumper.exe was not found after extraction.'
}

$libPath = Join-Path $UnpackedDir 'lib\arm64-v8a\libil2cpp.so'
$metadataPath = Join-Path $UnpackedDir 'assets\bin\Data\Managed\Metadata\global-metadata.dat'

Assert-FileExists -Path $libPath
Assert-FileExists -Path $metadataPath

Write-Section 'Running Il2CppDumper v39'
Write-Host "Binary:   $libPath"
Write-Host "Metadata: $metadataPath"
Write-Host "Output:   $OutDir"

& $exe.FullName $libPath $metadataPath $OutDir
if ($LASTEXITCODE -ne 0) {
    throw "Il2CppDumper exited with code $LASTEXITCODE."
}

Write-Host 'Il2CppDumper v39 completed.'
