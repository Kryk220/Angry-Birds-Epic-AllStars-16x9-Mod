# Shared helpers for the Angry Birds Epic 16:9 patcher.
# Dot-source this file from the other scripts: . "$PSScriptRoot\common.ps1"

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:PatcherDir = $PSScriptRoot
$script:RepoRoot = Split-Path -Parent $PSScriptRoot
if ([string]::IsNullOrEmpty($script:RepoRoot)) {
    $script:RepoRoot = (Get-Location).Path
}

function Get-RepoRoot {
    return $script:RepoRoot
}

function Get-DefaultToolsDir {
    return (Join-Path $script:RepoRoot 'Soft')
}

function Resolve-JavaExe {
    param(
        [string]$ToolsDir = ''
    )

    $candidates = New-Object System.Collections.Generic.List[string]
    if ($env:JAVA_HOME) {
        $candidates.Add((Join-Path $env:JAVA_HOME 'bin\java.exe'))
    }
    if (-not [string]::IsNullOrEmpty($ToolsDir)) {
        $candidates.Add((Join-Path $ToolsDir 'jdk\bin\java.exe'))
    }
    if (-not [string]::IsNullOrEmpty($env:USERPROFILE)) {
        $candidates.Add((Join-Path $env:USERPROFILE 'scoop\apps\openjdk17\current\bin\java.exe'))
    }

    foreach ($candidate in $candidates) {
        if (Test-Path -LiteralPath $candidate) {
            return $candidate
        }
    }

    $command = Get-Command 'java.exe' -ErrorAction SilentlyContinue
    if ($command) {
        return $command.Source
    }

    throw "Java was not found. Install JDK 17+ (https://adoptium.net) or run .\patcher\install_jdk.ps1."
}

function Assert-FileExists {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [string]$Hint = ''
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        $message = "File not found: $Path"
        if (-not [string]::IsNullOrEmpty($Hint)) {
            $message += "`n$Hint"
        }
        throw $message
    }
}

function Invoke-Java {
    param(
        [Parameter(Mandatory = $true)][string]$JavaExe,
        [Parameter(Mandatory = $true)][string[]]$Arguments
    )

    & $JavaExe @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "Java exited with code $LASTEXITCODE."
    }
}

function Convert-HexToBytes {
    param(
        [Parameter(Mandatory = $true)][string]$Hex
    )

    $clean = ($Hex -replace '[^0-9A-Fa-f]', '')
    if (($clean.Length % 2) -ne 0) {
        throw "Hex string has an odd number of characters: $Hex"
    }

    $bytes = New-Object byte[] ($clean.Length / 2)
    for ($i = 0; $i -lt $bytes.Length; $i++) {
        $bytes[$i] = [Convert]::ToByte($clean.Substring($i * 2, 2), 16)
    }
    return $bytes
}

function Get-HexAt {
    param(
        [Parameter(Mandatory = $true)][byte[]]$Bytes,
        [Parameter(Mandatory = $true)][int64]$Offset,
        [Parameter(Mandatory = $true)][int]$Length
    )

    if ($Offset -lt 0 -or ($Offset + $Length) -gt $Bytes.Length) {
        throw "Patch range 0x$($Offset.ToString('X')) + $Length is outside the file (size $($Bytes.Length))."
    }

    $builder = New-Object System.Text.StringBuilder
    for ($i = 0; $i -lt $Length; $i++) {
        [void]$builder.Append($Bytes[$Offset + $i].ToString('X2'))
    }
    return $builder.ToString()
}

function Write-Section {
    param([Parameter(Mandatory = $true)][string]$Text)
    Write-Host ''
    Write-Host "== $Text ==" -ForegroundColor Cyan
}
