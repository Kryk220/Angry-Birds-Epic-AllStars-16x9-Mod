# Inspects an apktool-decoded APK: Unity build type, engine version,
# activities/orientation and the contents of assets\bin\Data.

[CmdletBinding()]
param(
    [string]$UnpackedDir = ''
)

. "$PSScriptRoot\..\common.ps1"

if ([string]::IsNullOrEmpty($UnpackedDir)) {
    $UnpackedDir = Join-Path (Get-RepoRoot) 'unpacked'
}

if (-not (Test-Path -LiteralPath $UnpackedDir)) {
    throw "Unpacked directory not found: $UnpackedDir"
}

Write-Section '1. Unity build type'
$assemblyCSharp = Join-Path $UnpackedDir 'assets\bin\Data\Managed\Assembly-CSharp.dll'
$libil2cpp = Join-Path $UnpackedDir 'lib\arm64-v8a\libil2cpp.so'
$metadata = Join-Path $UnpackedDir 'assets\bin\Data\Managed\Metadata\global-metadata.dat'

if (Test-Path -LiteralPath $assemblyCSharp) {
    Write-Host 'Build type: MONO (Assembly-CSharp.dll found)'
}
elseif ((Test-Path -LiteralPath $libil2cpp) -or (Test-Path -LiteralPath $metadata)) {
    Write-Host 'Build type: IL2CPP (IL2CPP artifacts found)'
}
else {
    Write-Host 'Build type: unknown, check the lib folder'
    Get-ChildItem -LiteralPath (Join-Path $UnpackedDir 'lib') -Recurse -ErrorAction SilentlyContinue |
        Select-Object FullName
}

Write-Section '2. Unity engine version'
$globalGameManagers = Join-Path $UnpackedDir 'assets\bin\Data\globalgamemanagers'
if (-not (Test-Path -LiteralPath $globalGameManagers)) {
    $globalGameManagers = Join-Path $UnpackedDir 'assets\bin\Data\data.unity3d'
}
if (Test-Path -LiteralPath $globalGameManagers) {
    $bytes = [IO.File]::ReadAllBytes($globalGameManagers)
    $take = [Math]::Min(1024, $bytes.Length)
    $text = [Text.Encoding]::ASCII.GetString($bytes, 0, $take)
    $printable = -join ($text.ToCharArray() | ForEach-Object {
        if ([int]$_ -ge 32 -and [int]$_ -le 126) { $_ } else { ' ' }
    })
    Write-Host "First 1024 bytes of $(Split-Path -Leaf $globalGameManagers):"
    Write-Host $printable
}
else {
    Write-Host 'globalgamemanagers / data.unity3d not found.'
}

Write-Section '3. AndroidManifest.xml'
$manifestPath = Join-Path $UnpackedDir 'AndroidManifest.xml'
if (Test-Path -LiteralPath $manifestPath) {
    [xml]$manifest = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8
    $android = 'http://schemas.android.com/apk/res/android'

    $app = $manifest.manifest.application
    foreach ($activity in $app.activity) {
        $name = $activity.GetAttribute('name', $android)
        $orientation = $activity.GetAttribute('screenOrientation', $android)
        $resizeable = $activity.GetAttribute('resizeableActivity', $android)
        Write-Host "Activity: $name"
        Write-Host "  screenOrientation: $orientation"
        Write-Host "  resizeableActivity: $resizeable"
    }

    foreach ($meta in $app.meta_data) {
        $name = $meta.GetAttribute('name', $android)
        $value = $meta.GetAttribute('value', $android)
        if ($name -like '*AspectRatio*' -or $name -like '*max_aspect*') {
            Write-Host "meta-data: $name = $value"
        }
    }
}
else {
    Write-Host 'AndroidManifest.xml not found.'
}

Write-Section '4. assets\bin\Data'
$dataDir = Join-Path $UnpackedDir 'assets\bin\Data'
if (Test-Path -LiteralPath $dataDir) {
    Get-ChildItem -LiteralPath $dataDir -File | Select-Object Name, Length | Format-Table -AutoSize
}
else {
    Write-Host 'assets\bin\Data not found.'
}
