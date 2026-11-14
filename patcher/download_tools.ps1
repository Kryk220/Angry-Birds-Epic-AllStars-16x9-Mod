# Downloads the two build tools used by this project: apktool and uber-apk-signer.
# Java is NOT downloaded here; use .\patcher\install_jdk.ps1 if you do not have a JDK.

[CmdletBinding()]
param(
    [string]$ToolsDir = '',
    [switch]$Force
)

. "$PSScriptRoot\common.ps1"

if ([string]::IsNullOrEmpty($ToolsDir)) {
    $ToolsDir = Get-DefaultToolsDir
}

New-Item -ItemType Directory -Force -Path $ToolsDir | Out-Null

$apktoolUrl = 'https://github.com/iBotPeaches/Apktool/releases/download/v2.9.3/apktool_2.9.3.jar'
$signerUrl = 'https://github.com/patrickfav/uber-apk-signer/releases/download/v1.3.0/uber-apk-signer-1.3.0.jar'

function Get-Tool {
    param(
        [Parameter(Mandatory = $true)][string]$Url,
        [Parameter(Mandatory = $true)][string]$Destination
    )

    if ((Test-Path -LiteralPath $Destination) -and (-not $Force)) {
        Write-Host "Already present: $Destination"
        return
    }

    Write-Host "Downloading $Url"
    Invoke-WebRequest -Uri $Url -OutFile $Destination -UseBasicParsing

    $size = (Get-Item -LiteralPath $Destination).Length
    if ($size -lt 100000) {
        throw "Download looks incomplete: $Destination ($size bytes)."
    }
    Write-Host "Saved $Destination ($size bytes)"
}

Get-Tool -Url $apktoolUrl -Destination (Join-Path $ToolsDir 'apktool.jar')
Get-Tool -Url $signerUrl -Destination (Join-Path $ToolsDir 'uber-apk-signer.jar')

Write-Section 'Tools ready'
Write-Host "apktool:          $(Join-Path $ToolsDir 'apktool.jar')"
Write-Host "uber-apk-signer:  $(Join-Path $ToolsDir 'uber-apk-signer.jar')"
Write-Host ''
Write-Host 'Next: .\patcher\build.ps1 -ApkPath "C:\path\to\All Stars 1.2.8.1.apk"'
