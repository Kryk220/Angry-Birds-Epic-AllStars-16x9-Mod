# Patcher

Portable PowerShell scripts that rebuild the 16:9 / widescreen APK from the
original Angry Birds Epic (All Stars 1.2.8.1) APK.

## Requirements

- Windows 10/11 with PowerShell 5.1+
- Java JDK 17+ (`JAVA_HOME` or `java.exe` on `PATH`), or run `install_jdk.ps1`
- apktool 2.9.3 and uber-apk-signer 1.3.0 (downloaded automatically)
- The original APK: `All Stars 1.2.8.1.apk` (versionCode `4823`, versionName `3.0.27463.4823`)

## Quick start (from the repository root)

```powershell
powershell -ExecutionPolicy Bypass -File .\patcher\download_tools.ps1
powershell -ExecutionPolicy Bypass -File .\patcher\build.ps1 -ApkPath "C:\path\to\All Stars 1.2.8.1.apk"
```

Result:

```
release_build\AngryBirdsEpic_16x9_signed.apk
```

## Scripts

| Script | Purpose |
| --- | --- |
| `common.ps1` | Shared helpers: Java lookup, hex/byte utilities |
| `download_tools.ps1` | Downloads apktool and uber-apk-signer into `..\Soft` |
| `install_jdk.ps1` | Downloads a portable Temurin JDK 17 (optional) |
| `unpack_and_setup.ps1` | Decodes the APK with apktool into `..\unpacked` |
| `apply_patch.ps1` | Verifies and applies the libil2cpp.so + manifest patch |
| `repack_sign.ps1` | Rebuilds with apktool, zipaligns and signs |
| `build.ps1` | Runs the whole pipeline end to end |
| `verify_apk.ps1` | Checks that a built APK contains the expected bytes |
| `apktool.bat` | Portable wrapper for manual apktool use |

## Manual pipeline (from the repository root)

```powershell
.\patcher\unpack_and_setup.ps1 -ApkPath "C:\path\to\All Stars 1.2.8.1.apk" -Force
.\patcher\apply_patch.ps1
.\patcher\repack_sign.ps1
.\patcher\verify_apk.ps1 -ApkPath .\release_build\AngryBirdsEpic_16x9_signed.apk
```

All paths are relative to the repository, so the scripts work from any folder.
`-ToolsDir`, `-OutDir` and `-UnpackedDir` let you override the defaults.

## The patch

`libil2cpp.so` (`lib/arm64-v8a`) is patched at two file offsets:

| Method | Offset | Original bytes | Patched bytes | Result |
| --- | --- | --- | --- | --- |
| `UnityEngine.Screen.get_width` | `0x2619028` | `FE4FBFA9D31F0090` | `00F08052C0035FD6` | `MOVZ W0, #1920; RET` |
| `UnityEngine.Screen.get_height` | `0x2619050` | `FE4FBFA9D31F0090` | `00878052C0035FD6` | `MOVZ W0, #1080; RET` |

The game's camera/UI manager reads `Screen.width` and `Screen.height` to pick a
camera viewport. Reporting a fixed 1920x1080 reference makes the UI and cameras
lay out for a 16:9 surface instead of shrinking everything into a narrow strip.

The patcher also adds this element to `<application>` in `AndroidManifest.xml`:

```xml
<meta-data android:name="android.max_aspect" android:value="1.778" />
```

Every offset is validated against the original bytes before writing. If the
bytes do not match, the script aborts, so it cannot silently corrupt a
different APK version.

Backups are created next to the files (`libil2cpp.so.orig`,
`AndroidManifest.xml.orig`). Use `.\apply_patch.ps1 -Restore` to roll back.

## Full-bleed 20:9 variant

By default the manifest declares a 16:9 maximum aspect ratio. Most phones will
still render the game full-width when "full screen mode" is enabled for the app.
To build without the aspect-ratio declaration:

```powershell
.\patcher\build.ps1 -ApkPath "..." -SkipManifest
```

This is experimental: behaviour depends on the device's aspect-ratio handling.

## Custom signing key

```powershell
.\patcher\repack_sign.ps1 `
  -Keystore "C:\keys\release.jks" `
  -KsAlias "mykey" `
  -KsPass "store-password" `
  -KeyPass "key-password"
```

Without `-Keystore`, uber-apk-signer uses its debug key.

## Analysis helpers

`analysis/` contains optional reverse-engineering scripts (Il2CppDumper,
`dump.cs` search, manifest inspection). They are not required to build the mod.
See `analysis/README.md`.
