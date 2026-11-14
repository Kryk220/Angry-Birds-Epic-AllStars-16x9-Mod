# Searches an Il2CppDumper dump.cs for aspect-ratio / camera / viewport symbols.
# Optional helper - not needed to build the mod.

[CmdletBinding()]
param(
    [string]$DumpDir = '',
    [string]$UnpackedDir = ''
)

. "$PSScriptRoot\..\common.ps1"

if ([string]::IsNullOrEmpty($DumpDir)) {
    $DumpDir = Join-Path (Get-RepoRoot) 'il2cpp_dump'
}
if ([string]::IsNullOrEmpty($UnpackedDir)) {
    $UnpackedDir = Join-Path (Get-RepoRoot) 'unpacked'
}

$dumpCs = Join-Path $DumpDir 'dump.cs'
$bootConfig = Join-Path $UnpackedDir 'assets\bin\Data\boot.config'

Write-Section 'boot.config'
if (Test-Path -LiteralPath $bootConfig) {
    Get-Content -LiteralPath $bootConfig
}
else {
    Write-Host 'boot.config not found.'
}

Write-Section 'Searching dump.cs'
if (-not (Test-Path -LiteralPath $dumpCs)) {
    throw "dump.cs not found: $dumpCs`nRun .\patcher\analysis\run_dumper_v39.ps1 first."
}

$keywords = @(
    'Aspect', 'Resolution', 'Letterbox', 'Camera', 'Viewport',
    'Screen', 'CanvasScaler', '1.777', '1.333', '16', '9'
)

foreach ($keyword in $keywords) {
    Write-Host ''
    Write-Host "--- $keyword ---"
    Select-String -LiteralPath $dumpCs -Pattern $keyword -SimpleMatch -CaseSensitive:$false |
        Select-Object -First 15 |
        ForEach-Object { Write-Host "$($_.LineNumber): $($_.Line.Trim())" }
}
