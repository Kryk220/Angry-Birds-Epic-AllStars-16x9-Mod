# Angry Birds Epic All Stars — 16:9 Aspect Ratio Mod

**English** | [Русский](#русский)

An unofficial client-side patch built specifically for the fan-made mod **[Angry Birds Epic All Stars](https://discord.com/invite/ab-epic-all-stars-1214378014545158195)** (v1.2.8.1). It forces the game to run in a standard **16:9** aspect ratio (1920×1080 reference) on modern widescreen phones (such as 20:9 displays). Instead of stretching or breaking the layout across ultra-wide screens, the game runs cleanly in a fixed 16:9 frame (with standard black side bars on 20:9 panels), fixing UI and camera bugs.

> ⚠️ **Disclaimer:** I am a beginner in coding and reverse engineering. This patch was created using **AI-assisted development ("vibe coding")**. It has been tested and works as intended, though minor visual glitches or edge cases may still occur. Please note that **this project is provided "as is" and I do not plan to update or maintain it further**.

## English

### What it fixes

* **Forced 16:9 aspect ratio on modern screens** — locks **Angry Birds Epic All Stars** to a standard 16:9 frame (with clean black side bars on 20:9 displays) instead of trying to stretch across ultra-wide panels.

* **Correct UI scaling** — HUD, cards, buttons, and battle UI stay properly positioned inside the 16:9 frame and keep their proportions instead of stretching or clipping.

* **Correct camera viewport** — fixes camera zoom and cropping issues caused by a mismatch between the render resolution and tall display aspect ratios.

* **Stable 1920×1080 reference resolution** — makes Unity's `Screen.width` / `Screen.height` return `1920×1080`, the values expected by the game's `CameraResolutionMgr` for proper layout.

* **No gameplay changes** — visuals and aspect ratio only; all All Stars content, progression, saves, and balance remain untouched.

### Tested compatibility

|  |  | 
| ----- | ----- | 
| Base mod | [Angry Birds Epic All Stars](https://discord.com/invite/ab-epic-all-stars-1214378014545158195) 1.2.8.1 | 
| versionCode / versionName | `4823` / `3.0.27463.4823` | 
| Test device | POCO F6 | 
| OS | Android 16 (HyperOS) | 
| ABI | `arm64-v8a` (64-bit) | 
| Minimum Android | 8.0 / API 25 | 
| Test result | **20+ levels completed**, stable, no crashes, no UI clipping | 

The `armeabi-v7a` library is left untouched; use a 64-bit device.

### Installation

1. Download the prebuilt APK directly from this repository or from the [Releases](../../releases) page.

2. Uninstall any existing version of **Angry Birds Epic** / **All Stars** first — it is signed with a different key.

3. Allow installation from unknown sources for your file manager or browser.

4. Install and launch the game.

5. On tall 20:9 phones, keep the app in standard 16:9 / non-stretched mode if your system tries to force full-screen stretching (HyperOS: Settings → Display → Full screen mode → disable forced stretching for Angry Birds Epic).

### Build from the original All Stars APK (Optional)

If you prefer to patch your own **Angry Birds Epic All Stars** APK file manually, build scripts are included in the repository:

#### Requirements

* Windows 10/11, PowerShell 5.1+

* Java JDK 17+ (Temurin recommended)

* apktool 2.9.3

* uber-apk-signer 1.3.0

* Base mod APK: `All Stars 1.2.8.1.apk` (versionCode 4823, available via the [official All Stars Discord](https://discord.com/invite/ab-epic-all-stars-1214378014545158195))

`apktool` and `uber-apk-signer` are downloaded automatically. If Java is missing, the helper script installs a portable JDK 17.

#### One-command build

```powershell
git clone https://github.com/Kryk220/Angry-Birds-Epic-16x9-Mod.git
cd Angry-Birds-Epic-16x9-Mod

powershell -ExecutionPolicy Bypass -File .\patcher\download_tools.ps1

# only if Java is not installed:
powershell -ExecutionPolicy Bypass -File .\patcher\install_jdk.ps1

powershell -ExecutionPolicy Bypass -File .\patcher\build.ps1 `
  -ApkPath "C:\path\to\All Stars 1.2.8.1.apk"
```

Output:

```text
release_build\AngryBirdsEpic_16x9_signed.apk
```

#### Step by step

```powershell
# 1. Decode the original All Stars APK into .\unpacked
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
| ----- | ----- | ----- | 
| `UnityEngine.Screen.get_width` | `0x2619028` | `MOVZ W0, #1920; RET` | 
| `UnityEngine.Screen.get_height` | `0x2619050` | `MOVZ W0, #1080; RET` | 
| `AndroidManifest.xml` | `<application>` | adds `android.max_aspect = 1.778` | 

The original bytes are checked before patching, so an unsupported APK version is rejected instead of producing a broken build. Technical details: [`patcher/README.md`](patcher/README.md).

#### Experimental variant without 16:9 manifest cap

```powershell
.\patcher\build.ps1 -ApkPath "..." -SkipManifest
```

This omits the `1.778` (16:9) max aspect declaration while keeping the `1920×1080` screen resolution hooks.

### Repository layout

```text
.
├── patcher/            Portable build scripts and patch definition
│   └── analysis/       Optional reverse-engineering helpers
├── docs/               Screenshots and extra documentation
├── .gitignore
├── LICENSE
└── README.md
```

### Troubleshooting

| Problem | Solution | 
| ----- | ----- | 
| `INSTALL_FAILED_UPDATE_INCOMPATIBLE` | Uninstall the existing/Play Store version; the signatures differ. | 
| `App not installed` | Check free space (~600 MB), Android 8+ and a 64-bit device. | 
| `Java was not found` | Install JDK 17 or run `.\patcher\install_jdk.ps1`. | 
| `Unexpected bytes at 0x...` | Your APK is a different build. Use All Stars 1.2.8.1 (versionCode 4823). | 
| Scripts are blocked | Run PowerShell with `-ExecutionPolicy Bypass`. | 
| UI still stretches on 20:9 | Disable forced full-screen mode for the app in system display settings. | 

### Legal

This is an unofficial fan add-on for **Angry Birds Epic All Stars** and is not affiliated with, endorsed by, or sponsored by the All Stars team, Rovio Entertainment, or SEGA. Angry Birds and all related names, characters and assets are trademarks of their respective owners. Use at your own risk.

### Credits

* **[Angry Birds Epic All Stars](https://discord.com/invite/ab-epic-all-stars-1214378014545158195)** — the base fan mod that this patch is built upon

* [apktool](https://github.com/iBotPeaches/Apktool) — APK decoding and rebuilding

* [uber-apk-signer](https://github.com/patrickfav/uber-apk-signer) — zipalign and signing

* [Il2CppDumper](https://github.com/Perfare/Il2CppDumper) — IL2CPP analysis

---

## Русский

Неофициальный клиентский патч, созданный специально для фанатского мода **[Angry Birds Epic All Stars](https://discord.com/invite/ab-epic-all-stars-1214378014545158195)** (версия 1.2.8.1). Он заставляет игру работать в классическом соотношении сторон **16:9** (опорное разрешение 1920×1080) на современных вытянутых экранах (например, 20:9). Вместо того чтобы растягиваться и ломать вёрстку на нестандартных дисплеях, игра запускается в чёткой рамке 16:9 (с аккуратными чёрными полосами по бокам на экранах 20:9), благодаря чему полностью исправляются баги интерфейса и камеры.

> ⚠️ **Важно (Дисклеймер):** Я не профессиональный программист и только набираюсь опыта в кодинге и реверс-инжиниринге. Этот патч был написан при активной помощи **ИИ (вайбкодинг / vibe coding)**. Мод проверен и работает стабильно, хотя в редких случаях могут встречаться мелкие визуальные неточности. Обратите внимание: **патч выложен «как есть» (as is), и я не планирую его обновлять или дорабатывать в будущем**.

### Что исправляет патч

* **Принудительная работа в 16:9 на современных экранах** — фиксирует **Angry Birds Epic All Stars** в стандартном соотношении сторон 16:9 (на вытянутых экранах 20:9 появляются стандартные чёрные полосы по бокам, чтобы картинка не искажалась).

* **Корректное масштабирование UI** — HUD, карточки, кнопки и боевой интерфейс остаются строго внутри экрана, не растягиваются и не обрезаются по краям.

* **Исправление камеры и обзора** — устраняет неправильный зум и обрезание игрового мира, возникающие из-за несовпадения рендера и вытянутого экрана.

* **Стабильное опорное разрешение 1920×1080** — патч заставляет `UnityEngine.Screen.width` и `Screen.height` возвращать `1920×1080` — именно эти значения использует `CameraResolutionMgr` для корректной раскладки UI и камер.

* **Геймплей не меняется** — исправляется только отображение и соотношение сторон; весь контент мода All Stars, прогресс, сохранения и баланс остаются прежними.

### Проверенная совместимость

|  |  | 
| ----- | ----- | 
| Базовый мод | [Angry Birds Epic All Stars](https://discord.com/invite/ab-epic-all-stars-1214378014545158195) 1.2.8.1 | 
| versionCode / versionName | `4823` / `3.0.27463.4823` | 
| Тестовое устройство | POCO F6 | 
| ОС | Android 16 (HyperOS) | 
| ABI | `arm64-v8a` (64-bit) | 
| Минимальный Android | 8.0 / API 25 | 
| Результат теста | **пройдено 20+ уровней**, стабильно, без вылетов и обрезания UI | 

Библиотека `armeabi-v7a` не изменяется — используйте 64-битное устройство.

### Установка

1. Скачайте готовый APK-файл прямо из этого репозитория или из раздела [Releases](../../releases).

2. Предварительно удалите уже установленную версию **Angry Birds Epic** или **All Stars**, так как у них разные цифровые подписи.

3. Разрешите установку приложений из неизвестных источников для вашего файлового менеджера или браузера.

4. Установите и запустите игру.

5. На вытянутых экранах 20:9 убедитесь, что система не пытается принудительно растянуть игру за пределы 16:9 (в HyperOS: Настройки → Экран → Полноэкранный режим → отключите принудительное растягивание для Angry Birds Epic).

### Сборка патча из оригинального APK All Stars (необязательно)

Если вы хотите самостоятельно пропатчить свой APK-файл **Angry Birds Epic All Stars**, в репозитории приложены скрипты сборки:

#### Требования

* Windows 10/11, PowerShell 5.1+

* Java JDK 17+ (рекомендуется Temurin)

* apktool 2.9.3

* uber-apk-signer 1.3.0

* APK базового мода: `All Stars 1.2.8.1.apk` (versionCode 4823, можно скачать на [официальном Discord-сервере All Stars](https://discord.com/invite/ab-epic-all-stars-1214378014545158195))

`apktool` и `uber-apk-signer` скачиваются автоматически. Если Java не установлена, вспомогательный скрипт поставит портативный JDK 17.

#### Сборка одной командой

```powershell
git clone https://github.com/Kryk220/Angry-Birds-Epic-16x9-Mod.git
cd Angry-Birds-Epic-16x9-Mod

powershell -ExecutionPolicy Bypass -File .\patcher\download_tools.ps1

# только если Java не установлена:
powershell -ExecutionPolicy Bypass -File .\patcher\install_jdk.ps1

powershell -ExecutionPolicy Bypass -File .\patcher\build.ps1 `
  -ApkPath "C:\path\to\All Stars 1.2.8.1.apk"
```

Результат:

```text
release_build\AngryBirdsEpic_16x9_signed.apk
```

#### Пошаговая сборка

```powershell
# 1. Распаковать оригинальный APK All Stars в .\unpacked
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
| ----- | ----- | ----- | 
| `UnityEngine.Screen.get_width` | `0x2619028` | `MOVZ W0, #1920; RET` | 
| `UnityEngine.Screen.get_height` | `0x2619050` | `MOVZ W0, #1080; RET` | 
| `AndroidManifest.xml` | `<application>` | добавляется `android.max_aspect = 1.778` | 

Перед записью патчер сверяет оригинальные байты. Если APK другой версии, сборка прерывается — испорченный файл не создаётся. Подробности: [`patcher/README.md`](patcher/README.md).

#### Экспериментальный вариант без ограничения 1.778 в манифесте

```powershell
.\patcher\build.ps1 -ApkPath "..." -SkipManifest
```

Флаг убирает ограничение аспекта `1.778` (16:9) из `AndroidManifest.xml`, оставляя подмену разрешения `1920×1080` в коде.

### Структура репозитория

```text
.
├── patcher/            Переносимые скрипты сборки и описание патча
│   └── analysis/       Дополнительные утилиты реверс-инжиниринга
├── docs/               Скриншоты и документация
├── .gitignore
├── LICENSE
└── README.md
```

### Решение проблем

| Проблема | Решение | 
| ----- | ----- | 
| `INSTALL_FAILED_UPDATE_INCOMPATIBLE` | Удалите старую версию/версию из Play Store — подписи различаются. | 
| `Приложение не установлено` | Проверьте свободное место (~600 МБ), Android 8+ и 64-битное устройство. | 
| `Java was not found` | Установите JDK 17 или запустите `.\patcher\install_jdk.ps1`. | 
| `Unexpected bytes at 0x...` | APK другой сборки. Нужен мод All Stars 1.2.8.1 (versionCode 4823). | 
| Скрипты заблокированы | Запускайте PowerShell с `-ExecutionPolicy Bypass`. | 
| Интерфейс всё равно растягивается на 20:9 | Отключите принудительный полноэкранный режим для игры в настройках экрана. | 

### Правовая информация

Это неофициальное фанатское дополнение к моду **Angry Birds Epic All Stars**. Проект не связан с командой разработчиков All Stars, Rovio Entertainment или SEGA, не одобрен и не спонсируется ими. Angry Birds и все связанные названия, персонажи и материалы являются торговыми марками их владельцев. Используйте на свой риск.

### Благодарности

* **[Angry Birds Epic All Stars](https://discord.com/invite/ab-epic-all-stars-1214378014545158195)** — базовый фанатский мод, на основе которого сделан этот патч

* [apktool](https://github.com/iBotPeaches/Apktool) — распаковка и сборка APK

* [uber-apk-signer](https://github.com/patrickfav/uber-apk-signer) — выравнивание и подпись

* [Il2CppDumper](https://github.com/Perfare/Il2CppDumper) — анализ IL2CPP
