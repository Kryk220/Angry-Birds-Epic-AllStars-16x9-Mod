# Applies the 16:9 / widescreen patch to an apktool-decoded APK.
#
# The patch is intentionally strict: every target offset is verified against
# the original bytes before anything is written. If the base APK is a different
# version, the script stops instead of corrupting libil2cpp.so.

[CmdletBinding()]
param(
    [string]$UnpackedDir = '',
    [string]$ConfigPath = '',
    [switch]$SkipManifest,
    [switch]$Restore
)

. "$PSScriptRoot\common.ps1"

if ([string]::IsNullOrEmpty($UnpackedDir)) {
    $UnpackedDir = Join-Path (Get-RepoRoot) 'unpacked'
}
if ([string]::IsNullOrEmpty($ConfigPath)) {
    $ConfigPath = Join-Path $PSScriptRoot 'patch_config.json'
}

Assert-FileExists -Path $ConfigPath
$config = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json

$libPath = Join-Path $UnpackedDir $config.library
$manifestPath = Join-Path $UnpackedDir 'AndroidManifest.xml'
$libBackup = "$libPath.orig"
$manifestBackup = "$manifestPath.orig"

Assert-FileExists -Path $libPath -Hint 'Run .\patcher\unpack_and_setup.ps1 first.'

if ($Restore) {
    Write-Section 'Restoring original files'
    if (-not (Test-Path -LiteralPath $libBackup)) {
        throw "Backup not found: $libBackup"
    }
    Copy-Item -LiteralPath $libBackup -Destination $libPath -Force
    Write-Host "Restored: $libPath"

    if (Test-Path -LiteralPath $manifestBackup) {
        Copy-Item -LiteralPath $manifestBackup -Destination $manifestPath -Force
        Write-Host "Restored: $manifestPath"
    }
    else {
        Write-Warning "No manifest backup found. Re-unpack the APK if you also need to revert the manifest change."
    }
    return
}

Write-Section "Applying $($config.name)"

if (-not (Test-Path -LiteralPath $libBackup)) {
    Copy-Item -LiteralPath $libPath -Destination $libBackup
    Write-Host "Backup created: $libBackup"
}

$bytes = [IO.File]::ReadAllBytes($libPath)
$beforeHash = (Get-FileHash -LiteralPath $libPath -Algorithm SHA256).Hash

foreach ($patch in $config.patches) {
    $offset = [int64]$patch.offset
    $originalBytes = Convert-HexToBytes -Hex $patch.original
    $patchedBytes = Convert-HexToBytes -Hex $patch.patched
    $currentHex = Get-HexAt -Bytes $bytes -Offset $offset -Length $patchedBytes.Length

    if ($currentHex -eq $patch.patched.ToUpperInvariant()) {
        Write-Host "  [skip]  $($patch.name) is already patched at $($patch.offsetHex)" -ForegroundColor Yellow
        continue
    }

    if ($currentHex -ne $patch.original.ToUpperInvariant()) {
        throw @"
Unexpected bytes at $($patch.offsetHex) for $($patch.name).
Expected original: $($patch.original)
Found:             $currentHex

This APK is probably a different version. Supported base:
  $($config.baseApk.fileName)
  versionName $($config.baseApk.versionName), versionCode $($config.baseApk.versionCode)
"@
    }

    for ($i = 0; $i -lt $patchedBytes.Length; $i++) {
        $bytes[$offset + $i] = $patchedBytes[$i]
    }
    Write-Host "  [patch] $($patch.name) at $($patch.offsetHex)" -ForegroundColor Green
    Write-Host "          $($patch.description)"
}

[IO.File]::WriteAllBytes($libPath, $bytes)
$afterHash = (Get-FileHash -LiteralPath $libPath -Algorithm SHA256).Hash

if (-not $SkipManifest) {
    if (-not (Test-Path -LiteralPath $manifestBackup)) {
        Copy-Item -LiteralPath $manifestPath -Destination $manifestBackup
        Write-Host "Backup created: $manifestBackup"
    }

    $androidNs = 'http://schemas.android.com/apk/res/android'
    $metaName = $config.manifest.metaDataName
    $metaValue = [string]$config.manifest.value

    [xml]$document = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8
    $application = $document.DocumentElement.SelectSingleNode('application')
    if (-not $application) {
        throw "Could not find <application> in $manifestPath"
    }

    $existing = $null
    foreach ($node in $application.SelectNodes('meta-data')) {
        if ($node.GetAttribute('name', $androidNs) -eq $metaName) {
            $existing = $node
            break
        }
    }

    if ($existing) {
        $existing.SetAttribute('value', $androidNs, $metaValue) | Out-Null
        Write-Host "  [meta]  $metaName = $metaValue (updated)"
    }
    else {
        $meta = $document.CreateElement('meta-data')
        $meta.SetAttribute('name', $androidNs, $metaName) | Out-Null
        $meta.SetAttribute('value', $androidNs, $metaValue) | Out-Null
        $application.PrependChild($meta) | Out-Null
        Write-Host "  [meta]  $metaName = $metaValue (added)"
    }

    $settings = New-Object System.Xml.XmlWriterSettings
    $settings.Indent = $true
    $settings.IndentChars = '    '
    $settings.NewLineChars = "`r`n"
    $settings.Encoding = New-Object System.Text.UTF8Encoding($false)
    $writer = [System.Xml.XmlWriter]::Create($manifestPath, $settings)
    try {
        $document.Save($writer)
    }
    finally {
        $writer.Close()
    }
}
else {
    Write-Host '  [meta]  skipped on request (-SkipManifest)'
}

Write-Section 'Patch applied'
Write-Host "Library: $libPath"
Write-Host "SHA256 before: $beforeHash"
Write-Host "SHA256 after:  $afterHash"
Write-Host ''
Write-Host 'Next: .\patcher\repack_sign.ps1'
