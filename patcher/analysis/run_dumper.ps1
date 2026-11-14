# Downloads Il2CppDumper and dumps the IL2CPP metadata of the decoded APK.
# Optional reverse-engineering helper - not needed to build the mod.

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
    $url = 'https://github.com/Perfare/Il2CppDumper/releases/download/v6.7.40/Il2CppDumper-win-v6.7.40.zip'
    $zipPath = Join-Path $ToolsDir 'Il2CppDumper.zip'
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
if (-not (Test-Path -LiteralPath $libPath)) {
    $libPath = (Get-ChildItem -LiteralPath (Join-Path $UnpackedDir 'lib') -Filter 'libil2cpp.so' -Recurse |
        Select-Object -First 1).FullName
}
$metadataPath = Join-Path $UnpackedDir 'assets\bin\Data\Managed\Metadata\global-metadata.dat'

Assert-FileExists -Path $libPath
Assert-FileExists -Path $metadataPath

Write-Section 'Running Il2CppDumper'
Write-Host "Binary:   $libPath"
Write-Host "Metadata: $metadataPath"
Write-Host "Output:   $OutDir"

& $exe.FullName $libPath $metadataPath $OutDir
if ($LASTEXITCODE -ne 0) {
    throw "Il2CppDumper exited with code $LASTEXITCODE."
}

Write-Host 'Il2CppDumper completed.'
