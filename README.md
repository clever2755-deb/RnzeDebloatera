# Debloater — Android System Optimizer

A professional-grade, ad-free Android debloater app built with **Flutter + Kotlin + Shizuku API**.
Safely disable or remove pre-installed system apps without root access.

---

## Project Structure

```
flutter_debloater/
├── android/
│   ├── app/
│   │   ├── src/main/
│   │   │   ├── kotlin/com/debloater/app/
│   │   │   │   └── MainActivity.kt        ← Kotlin bridge + Shizuku shell execution
│   │   │   ├── res/values/styles.xml
│   │   │   └── AndroidManifest.xml        ← Shizuku permission + provider declaration
│   │   ├── build.gradle                   ← Shizuku dependency lives here
│   │   └── proguard-rules.pro
│   ├── build.gradle
│   ├── gradle.properties
│   ├── settings.gradle
│   └── gradle/wrapper/gradle-wrapper.properties
├── lib/
│   ├── main.dart                          ← App entry, tab shell
│   ├── theme/app_theme.dart               ← AMOLED dark + cyan accent theme
│   ├── models/app_info.dart               ← AppInfo data model
│   ├── services/shizuku_service.dart      ← MethodChannel → Kotlin bridge
│   ├── utils/bloatware_list.dart          ← Curated safe-to-remove package list
│   ├── widgets/
│   │   ├── app_tile.dart                  ← Per-app list item with selection
│   │   └── status_card.dart               ← Shizuku live status banner
│   └── screens/
│       ├── dashboard_screen.dart          ← Scan + recommended removals
│       └── app_list_screen.dart           ← Full system app browser + filter
└── pubspec.yaml
```

---

## Prerequisites

| Tool | Version |
|------|---------|
| Flutter SDK | ≥ 3.0.0 |
| Android Studio | Hedgehog or newer |
| JDK | 17+ |
| Android device | API 26+ (Android 8.0+) |
| Shizuku app | ≥ 13.x (installed on device) |

---

## Step 1 — Open in Android Studio / VS Code

```bash
# Clone or copy this folder to your machine, then:
cd flutter_debloater
flutter pub get
```

---

## Step 2 — Verify Shizuku dependency in build.gradle

Open `android/app/build.gradle`. The Shizuku lines are already present:

```groovy
dependencies {
    // Shizuku API — shell process bridge
    implementation 'dev.rikka.shizuku:api:13.1.5'

    // Required for devices running Android < 11 (Shizuku < v11)
    implementation 'dev.rikka.shizuku:provider:13.1.5'
    ...
}
```

If you want to check for newer Shizuku versions:
👉 https://github.com/RikkaApps/Shizuku-API/releases

---

## Step 3 — Build the APK

### Debug APK (for testing)
```bash
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk
```

### Release APK (for distribution)
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Split APKs by ABI (smaller file sizes)
```bash
flutter build apk --split-per-abi
```

---

## Step 4 — Install on Device

```bash
flutter install
# or
adb install build/app/outputs/flutter-apk/app-debug.apk
```

---

## Step 5 — Setup Shizuku on the Device

### Method A — ADB (Wireless / USB)
```bash
adb shell sh /sdcard/Android/data/moe.shizuku.privileged.api/files/start.sh
```

### Method B — MIUI / Samsung Developer Mode
Some MIUI / One UI builds support starting Shizuku via USB debugging toggle in developer options.
See: https://shizuku.rikka.app/guide/setup/

---

## How It Works — Technical Flow

```
Flutter UI
    │
    ▼  MethodChannel("com.debloater.app/shizuku")
Kotlin (MainActivity.kt)
    │
    ▼  Shizuku.newProcess(["sh", "-c", command])
pm shell (Android Package Manager)
    │
    ▼  pm disable-user --user 0 <pkg>   → Disables for current user (reversible)
       pm uninstall -k --user 0 <pkg>   → Removes for current user, keeps data
       pm enable --user 0 <pkg>         → Re-enables a disabled app
```

All commands run as the **current user (user 0)** — no root, no system-level modifications.
Apps can always be restored via:
```bash
adb shell pm install-existing <package_name>
```

---

## Safety Design

- **Recommended list** (`lib/utils/bloatware_list.dart`): Only packages with `RiskLevel.safe` are flagged. Caution-level packages (e.g., Gmail, Maps) are listed but not auto-selected.
- **User 0 scope**: All `pm` commands use `--user 0`, affecting only the current user profile. System partition is untouched.
- **No silent actions**: Every disable/uninstall requires explicit user selection + confirmation dialog for uninstall.
- **No internet**: The app operates 100% offline. No analytics, no ads, no telemetry.

---

## Extending the Bloatware List

Edit `lib/utils/bloatware_list.dart` and add entries to the `packages` map:

```dart
'com.example.bloatapp': BloatwareEntry(
  name: 'Example Bloat',
  category: 'Carrier',
  risk: RiskLevel.safe,   // safe | caution | dangerous
),
```

---

## Permissions Declared

| Permission | Why |
|-----------|-----|
| `QUERY_ALL_PACKAGES` | Required on Android 11+ to list installed system apps |
| `moe.shizuku.manager.permission.API_V23` | Shizuku IPC permission |

---

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `Shizuku Not Running` | Open Shizuku app → Start service via ADB or wireless ADB |
| `Permission Required` | Tap "Grant" in the status card, then accept in the Shizuku permission dialog |
| `pm` command fails | Ensure Shizuku service is still alive; restart it if needed |
| Build fails — Kotlin version mismatch | Set `ext.kotlin_version = '1.9.22'` in `android/build.gradle` |
| `QUERY_ALL_PACKAGES` Play Store warning | For personal/sideloaded APKs this is fine; Play Store submission requires justification |

---

## License

MIT — Free to use, modify, and distribute. No warranty.
