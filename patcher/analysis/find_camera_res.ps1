# Prints the CameraResolutionMgr class (or any other symbol) from dump.cs.
# Optional helper - not needed to build the mod.

[CmdletBinding()]
param(
    [string]$DumpCs = '',
    [string]$Pattern = 'CameraResolutionMgr',
    [int]$Context = 30
)

. "$PSScriptRoot\..\common.ps1"

if ([string]::IsNullOrEmpty($DumpCs)) {
    $DumpCs = Join-Path (Get-RepoRoot) 'il2cpp_dump\dump.cs'
}

if (-not (Test-Path -LiteralPath $DumpCs)) {
    throw "dump.cs not found: $DumpCs`nRun .\patcher\analysis\run_dumper_v39.ps1 first."
}

Write-Section "Searching for $Pattern"
Select-String -LiteralPath $DumpCs -Pattern $Pattern -Context 0, $Context | ForEach-Object {
    $_.Context.PreContext
    $_.Line
    $_.Context.PostContext
    '-------------------------------------------'
}
