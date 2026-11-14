# Prints a line range from dump.cs. The defaults point at the CameraResolutionMgr
# block in the dump produced for version 3.0.27463.4823.
# Optional helper - not needed to build the mod.

[CmdletBinding()]
param(
    [string]$DumpCs = '',
    [int]$StartLine = 21550,
    [int]$EndLine = 21650
)

. "$PSScriptRoot\..\common.ps1"

if ([string]::IsNullOrEmpty($DumpCs)) {
    $DumpCs = Join-Path (Get-RepoRoot) 'il2cpp_dump\dump.cs'
}

if (-not (Test-Path -LiteralPath $DumpCs)) {
    throw "dump.cs not found: $DumpCs`nRun .\patcher\analysis\run_dumper_v39.ps1 first."
}

$lines = Get-Content -LiteralPath $DumpCs
$last = [Math]::Min($EndLine, $lines.Count)

for ($i = $StartLine; $i -le $last; $i++) {
    Write-Host "$i`: $($lines[$i - 1])"
}
