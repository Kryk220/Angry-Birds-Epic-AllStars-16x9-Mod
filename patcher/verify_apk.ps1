# Verifies that a signed APK contains the expected patched libil2cpp.so bytes.

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$ApkPath,
    [string]$ConfigPath = ''
)

. "$PSScriptRoot\common.ps1"

if ([string]::IsNullOrEmpty($ConfigPath)) {
    $ConfigPath = Join-Path $PSScriptRoot 'patch_config.json'
}

Assert-FileExists -Path $ConfigPath
$config = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
$apk = (Resolve-Path -LiteralPath $ApkPath).Path

Add-Type -AssemblyName System.IO.Compression.FileSystem

$tempFile = Join-Path ([IO.Path]::GetTempPath()) ("abe_verify_" + [Guid]::NewGuid().ToString('N') + '.so')
$zip = [IO.Compression.ZipFile]::OpenRead($apk)
try {
    $entry = $zip.GetEntry($config.library)
    if (-not $entry) {
        throw "Entry not found in APK: $($config.library)"
    }
    [IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $tempFile, $true)
}
finally {
    $zip.Dispose()
}

try {
    $bytes = [IO.File]::ReadAllBytes($tempFile)
    $allPatched = $true

    Write-Section "Verifying $(Split-Path -Leaf $apk)"
    Write-Host "Library: $($config.library)"
    Write-Host "SHA256:  $((Get-FileHash -LiteralPath $tempFile -Algorithm SHA256).Hash)"
    Write-Host ''

    foreach ($patch in $config.patches) {
        $hex = Get-HexAt -Bytes $bytes -Offset ([int64]$patch.offset) -Length (Convert-HexToBytes $patch.patched).Length
        if ($hex -eq $patch.patched.ToUpperInvariant()) {
            Write-Host "  [ OK ] $($patch.name) at $($patch.offsetHex)" -ForegroundColor Green
        }
        else {
            Write-Host "  [FAIL] $($patch.name) at $($patch.offsetHex) - found $hex" -ForegroundColor Red
            $allPatched = $false
        }
    }

    if (-not $allPatched) {
        throw 'The APK does not contain all expected patches.'
    }

    Write-Host ''
    Write-Host 'All patches verified.' -ForegroundColor Green
}
finally {
    if (Test-Path -LiteralPath $tempFile) {
        Remove-Item -LiteralPath $tempFile -Force
    }
}
