# Analysis helpers (optional)

These scripts document how the patch was found and are not needed to build the
APK. They assume an apktool-decoded APK in `..\..\unpacked` and write dumps to
`..\..\il2cpp_dump` by default.

| Script | Purpose |
| --- | --- |
| `analyze_unpacked.ps1` | Unity build type, engine version, manifest activities |
| `analyze_dump.ps1` | Searches `dump.cs` for aspect/camera/resolution symbols |
| `find_camera_res.ps1` | Prints `CameraResolutionMgr` (or any pattern) with context |
| `print_camera_res.ps1` | Prints a line range of `dump.cs` |
| `run_dumper.ps1` | Downloads Il2CppDumper 6.7.40 and dumps the APK |
| `run_dumper_v39.ps1` | Same, with the c01ns v39 metadata fork |

Typical use:

```powershell
.\run_dumper_v39.ps1
.\find_camera_res.ps1
```

Generated `dump.cs`, `il2cpp.h`, `script.json`, `stringliteral.json` and the
unpacked tree are git-ignored.
