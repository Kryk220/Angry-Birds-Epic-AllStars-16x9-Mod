# Angry Birds Epic — 16:9 / Widescreen Mod

**English** | [Русский](#русский)

An unofficial client-side patch that makes Angry Birds Epic use the full width of
modern 16:9 and 20:9 phones. The game's UI and cameras are laid out against a
fixed 1920×1080 reference instead of being squeezed into a legacy aspect-ratio
window, so the whole picture is visible without black side bars.

> No game assets or APKs are distributed in this repository. The patcher only
> modifies a copy of the game that you already own.

---

## English

### What it fixes

- **Native 16:9 / 20:9 support** — the game fills the screen in landscape, with
  no pillarboxing or letterboxing.
- **Correct UI scaling** — HUD, cards, buttons and battle UI stay inside the
  screen and keep their proportions instead of stretching or clipping.
- **Correct camera viewport** — the world is no longer zoomed or cropped because
  of a mismatch between the render and display aspect ratio.
- **Stable 1920×1080 reference resolution** — the patch makes Unity's
  `Screen.width` / `Screen.height` return 1920×1080, the values used by the
  game's `CameraResolutionMgr` for layout.
- **No gameplay changes** — visuals only; progression, saves and balance are
  untouched.

### Tested compatibility

| | |
| --- | --- |
| Base game | Angry Birds Epic All Stars 1.2.8.1 |
| versionCode / versionName | `4823` / `3.0.27463.4823` |
| Test device | POCO F6 |
| OS | Android 16 (HyperOS) |
| ABI | `arm64-v8a` (64-bit) |
| Minimum Android | 8.0 / API 25 |
| Test result | **20+ levels completed**, stable, no crashes, no UI clipping |

The `armeabi-v7a` library is left untouched; use a 64-bit device.

### Installation

1. Download the APK from the [Releases](../../releases) page. Prebuilt APKs are
   not stored in git.
2. Uninstall the Google Play version first — it is signed with a different key.
3. Allow installation from unknown sources for your file manager or browser.
4. Install and launch the game.
5. On tall 20:9 phones, enable full-screen mode for the app if the system still
   shows side bars (HyperOS: Settings → Display → Full screen mode → Angry Birds
   Epic).

### Build from the original APK

#### Requirements

- Windows 10/11, PowerShell 5.1+
- Java JDK 17+ (Temurin recommended)
- apktool 2.9.3
- uber-apk-signer 1.3.0
- Original APK: `All Stars 1.2.8.1.apk` (versionCode 4823)

apktool and uber-apk-signer are downloaded automatically. If Java is missing,
the helper script installs a portable JDK 17.

#### One-command build

```powershell
git clone https://github.com/<your-account>/Angry-Birds-Epic-16x9-Mod.git
cd Angry-Birds-Epic-16x9-Mod

powershell -ExecutionPolicy Bypass -File .\patcher\download_tools.ps1

# only if Java is not installed:
powershell -ExecutionPolicy Bypass -File .\patcher\install_jdk.ps1

powershell -ExecutionPolicy Bypass -File .\patcher\build.ps1 `
  -ApkPath "C:\path\to\All Stars 1.2.8.1.apk"
```

Output:

```
release_build\AngryBirdsEpic_16x9_signed.apk
```

#### Step by step

```powershell
# 1. Decode the original APK into .\unpacked
.\patcher\unpack_and_setup.ps1 -ApkPath "C:\path\to\All Stars 1.2.8.1.apk" -Force

# 2. Apply the 16:9 patch (every target byte is verified first)
.\patcher\apply_patch.ps1

# 3. Rebuild, zipalign and sign
.\patcher\repack_sign.ps1

# 4. Verify the result
.\patcher\verify_apk.ps1 -ApkPath .\release_build\AngryBirdsEpic_16x9_signed.apk
```

#### What the patcher changes

| Target | Address | Change |
| --- | --- | --- |
| `UnityEngine.Screen.get_width` | `0x2619028` | `MOVZ W0, #1920; RET` |
| `UnityEngine.Screen.get_height` | `0x2619050` | `MOVZ W0, #1080; RET` |
| `AndroidManifest.xml` | `<application>` | adds `android.max_aspect = 1.778` |

The original bytes are checked before patching, so an unsupported APK version is
rejected instead of producing a broken build. Technical details:
[`patcher/README.md`](patcher/README.md).

#### Full-bleed 20:9 variant (experimental)

```powershell
.\patcher\build.ps1 -ApkPath "..." -SkipManifest
```

This omits the 16:9 aspect declaration. Use it if your device forces a 16:9
window and you want the game to use the whole 20:9 panel.

### Repository layout

```
.
├── patcher/            Portable build scripts and patch definition
│   └── analysis/       Optional reverse-engineering helpers
├── docs/               Screenshots and extra documentation
├── release_build/      Local output folder (git-ignored)
├── .gitignore
├── LICENSE
└── README.md
```

### Troubleshooting

| Problem | Solution |
| --- | --- |
| `INSTALL_FAILED_UPDATE_INCOMPATIBLE` | Uninstall the existing/Play Store version; the signatures differ. |
| `App not installed` | Check free space (~600 MB), Android 8+ and a 64-bit device. |
| `Java was not found` | Install JDK 17 or run `.\patcher\install_jdk.ps1`. |
| `Unexpected bytes at 0x...` | Your APK is a different build. Use versionCode 4823 / 1.2.8.1. |
| Scripts are blocked | Run PowerShell with `-ExecutionPolicy Bypass`. |
| Side bars are still visible | Enable full-screen mode for the app in system settings. |

### Legal

This is an unofficial fan project and is not affiliated with, endorsed by, or
sponsored by Rovio Entertainment or SEGA. Angry Birds and all related names,
characters and assets are trademarks of their respective owners.

No game assets or APKs are distributed in this repository. The patcher only
modifies a copy of the game that you already own. Use at your own risk.

The MIT license applies to the scripts and documentation in this repository
only.

### Credits

- [apktool](https://github.com/iBotPeaches/Apktool) — APK decoding and rebuilding
- [uber-apk-signer](https://github.com/patrickfav/uber-apk-signer) — zipalign and signing
- [Il2CppDumper](https://github.com/Perfare/Il2CppDumper) — IL2CPP analysis

---

<a id="russian"></a>
## Русский

Неофициальный клиентский патч, который включает нативное отображение Angry Birds
Epic на широких экранах 16:9 и 20:9. UI и камеры игры рассчитываются от опорного
разрешения 1920×1080, а не сжимаются в устаревшее окно с другим соотношением
сторон, поэтому картинка занимает всю ширину экрана без чёрных полос по бокам.

> В репозитории не распространяются игровые ресурсы или APK. Патчер изменяет
> только копию игры, которая уже есть у вас.

### Что исправляет и улучшает мод

- **Нативная поддержка широких экранов 16:9 / 20:9** — игра заполняет всю ширину
  экрана в альбомной ориентации, без чёрных полос по бокам.
- **Корректное масштабирование UI** — HUD, карточки, кнопки и боевой интерфейс
  больше не растягиваются и не обрезаются по краям.
- **Корректная работа камеры** — камера и вьюпорт рассчитываются под широкий
  экран; мир не «зумится» и не обрезается из-за несовпадения аспекта.
- **Стабильная опорная резолюция 1920×1080** — патч заставляет `Screen.width` и
  `Screen.height` возвращать 1920×1080; именно эти значения использует
  `CameraResolutionMgr` для раскладки UI и камер.
- **Геймплей не меняется** — только клиентская отрисовка; прогресс, сохранения и
  баланс остаются прежними.

### Проверенная совместимость

| | |
| --- | --- |
| Базовая игра | Angry Birds Epic All Stars 1.2.8.1 |
| versionCode / versionName | `4823` / `3.0.27463.4823` |
| Тестовое устройство | POCO F6 |
| ОС | Android 16 (HyperOS) |
| ABI | `arm64-v8a` (64-bit) |
| Минимальный Android | 8.0 / API 25 |
| Результат теста | **пройдено 20+ уровней**, стабильно, без вылетов и обрезания UI |

Библиотека `armeabi-v7a` не изменяется — используйте 64-битное устройство.

### Установка

1. Скачайте APK из раздела [Releases](../../releases). Готовые APK не хранятся в git.
2. Удалите версию из Google Play — у неё другая подпись.
3. Разрешите установку из неизвестных источников для файлового менеджера или
   браузера.
4. Установите и запустите игру.
5. На вытянутых экранах 20:9 включите полноэкранный режим для приложения, если
   система всё ещё показывает полосы по бокам (HyperOS: Настройки → Экран →
   Полноэкранный режим → Angry Birds Epic).

### Сборка мода из оригинального APK

#### Требования

- Windows 10/11, PowerShell 5.1+
- Java JDK 17+ (рекомендуется Temurin)
- apktool 2.9.3
- uber-apk-signer 1.3.0
- Оригинальный APK: `All Stars 1.2.8.1.apk` (versionCode 4823)

apktool и uber-apk-signer скачиваются автоматически. Если Java не установлена,
вспомогательный скрипт поставит портативный JDK 17.

#### Сборка одной командой

```powershell
git clone https://github.com/<ваш-аккаунт>/Angry-Birds-Epic-16x9-Mod.git
cd Angry-Birds-Epic-16x9-Mod

powershell -ExecutionPolicy Bypass -File .\patcher\download_tools.ps1

# только если Java не установлена:
powershell -ExecutionPolicy Bypass -File .\patcher\install_jdk.ps1

powershell -ExecutionPolicy Bypass -File .\patcher\build.ps1 `
  -ApkPath "C:\path\to\All Stars 1.2.8.1.apk"
```

Результат:

```
release_build\AngryBirdsEpic_16x9_signed.apk
```

#### Пошаговая сборка

```powershell
# 1. Распаковать оригинальный APK в .\unpacked
.\patcher\unpack_and_setup.ps1 -ApkPath "C:\path\to\All Stars 1.2.8.1.apk" -Force

# 2. Применить патч 16:9 (сначала проверяются все байты)
.\patcher\apply_patch.ps1

# 3. Пересобрать, выровнять и подписать
.\patcher\repack_sign.ps1

# 4. Проверить результат
.\patcher\verify_apk.ps1 -ApkPath .\release_build\AngryBirdsEpic_16x9_signed.apk
```

#### Что именно изменяет патчер

| Цель | Адрес | Изменение |
| --- | --- | --- |
| `UnityEngine.Screen.get_width` | `0x2619028` | `MOVZ W0, #1920; RET` |
| `UnityEngine.Screen.get_height` | `0x2619050` | `MOVZ W0, #1080; RET` |
| `AndroidManifest.xml` | `<application>` | добавляется `android.max_aspect = 1.778` |

Перед записью патчер сверяет оригинальные байты. Если APK другой версии, сборка
прерывается — испорченный файл не создаётся. Подробности:
[`patcher/README.md`](patcher/README.md).

#### Вариант без ограничения 16:9 для 20:9 (экспериментально)

```powershell
.\patcher\build.ps1 -ApkPath "..." -SkipManifest
```

Флаг убирает объявление аспекта 16:9. Пригодится, если устройство принудительно
показывает игру в окне 16:9, а вы хотите занять всю панель 20:9.

### Структура репозитория

```
.
├── patcher/            Переносимые скрипты сборки и описание патча
│   └── analysis/       Дополнительные утилиты реверс-инжиниринга
├── docs/               Скриншоты и документация
├── release_build/      Локальная папка с APK (игнорируется git)
├── .gitignore
├── LICENSE
└── README.md
```

### Решение проблем

| Проблема | Решение |
| --- | --- |
| `INSTALL_FAILED_UPDATE_INCOMPATIBLE` | Удалите старую версию/версию из Play Store — подписи различаются. |
| `Приложение не установлено` | Проверьте свободное место (~600 МБ), Android 8+ и 64-битное устройство. |
| `Java was not found` | Установите JDK 17 или запустите `.\patcher\install_jdk.ps1`. |
| `Unexpected bytes at 0x...` | APK другой сборки. Нужна версия 1.2.8.1 / versionCode 4823. |
| Скрипты заблокированы | Запускайте PowerShell с `-ExecutionPolicy Bypass`. |
| Полосы по бокам остались | Включите полноэкранный режим для приложения в настройках системы. |

### Правовая информация

Это неофициальный фанатский проект. Он не связан с Rovio Entertainment или SEGA,
не одобрен и не спонсируется ими. Angry Birds и все связанные названия, персонажи
и материалы являются торговыми марками их владельцев.

В репозитории не распространяются игровые ресурсы или APK. Патчер изменяет только
копию игры, которая уже есть у вас. Используйте на свой риск.

Лицензия MIT распространяется только на скрипты и документацию в этом
репозитории.

### Благодарности

- [apktool](https://github.com/iBotPeaches/Apktool) — распаковка и сборка APK
- [uber-apk-signer](https://github.com/patrickfav/uber-apk-signer) — выравнивание и подпись
- [Il2CppDumper](https://github.com/Perfare/Il2CppDumper) — анализ IL2CPP
