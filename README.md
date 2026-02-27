# Finito

[한국어](README_KO.md)

A cross-platform TODO app with cloud sync. Manage your tasks from web, desktop, or mobile — your data stays in sync across all devices via Google account.

**Live Demo**: https://finito-f95ea.web.app

## Features

- Task management with title, description, due date, priority, and reminders
- Categories for organizing tasks
- Search and filtering (status, priority, category)
- Sorting by due date, priority, or creation date
- Drag-and-drop reordering
- Push notification reminders via FCM (Web, Android)
- Admin dashboard for user management (grant/revoke admin, approve/reject users)
- Google and email authentication
- Dark / Light theme
- Responsive layout (mobile dialog on small screens, popup dialog on wide screens)
- Multilingual support (Korean / English)
- Works offline — syncs when you log in

## Download

Builds are available on the [GitHub Releases](https://github.com/ckr3453/finito/releases) page.

| Platform | File | Notes |
|----------|------|-------|
| Android | `Finito-Android.apk` | Allow install from unknown sources |
| Windows | `Finito-Windows-x64.zip` | Extract and run `finito.exe` |

## How to Use

1. Visit https://finito-f95ea.web.app
2. Log in with Google (or use without account for local-only mode)
3. Start adding tasks

Without login, tasks are stored locally in your browser. Log in to sync across devices.

### Supported Platforms

| Platform | App | Widget |
|----------|-----|--------|
| Web | Available | - |
| Android | Available | Available |
| Windows | Available | - |

## Architecture

### Local-First + Cloud-Synced

UI always reads from local DB (Drift/SQLite) for instant response. Firestore syncs in the background when online.

```
[UI] <--watches--> [Riverpod Providers]
                          |
                     [Repository]
                      /        \
              [Drift DB]    [Firestore]
           (always read)  (background sync)
```

### Tech Stack

| Area | Technology |
|------|------------|
| Framework | Flutter 3.38+ (Dart) |
| State Management | Riverpod 2.x (annotation + generator) |
| Local DB | Drift (SQLite ORM) — web uses IndexedDB fallback |
| Backend | Firebase (Firestore + Auth + Hosting + Cloud Functions) |
| Push Notifications | FCM (Cloud Functions + Firebase Messaging) |
| Routing | GoRouter |
| Models | Freezed + json_serializable |
| Widget Bridge | home_widget (Android) |

### Project Structure

```
lib/
├── core/              # Constants, extensions, theme, utils
├── data/              # Data layer
│   ├── database/      # Drift DB tables, DAOs
│   ├── datasources/   # Local + remote data sources
│   └── repositories/  # Repository implementations
├── domain/            # Entities (Freezed), enums, repository interfaces
├── presentation/      # UI layer
│   ├── screens/       # home, task_detail, task_editor, categories, search, settings, auth, admin
│   ├── providers/     # Riverpod providers
│   └── shared_widgets/
├── services/          # sync, notification, fcm, widget, connectivity, auth, user
├── routing/           # GoRouter config
functions/             # Firebase Cloud Functions (push reminders)
```

## Development

### Prerequisites

- Flutter 3.38+ (or FVM)
- Dart 3.10+
- Firebase CLI
- Node.js 20+ (for Cloud Functions)

### Setup

```bash
# Install dependencies
flutter pub get

# Firebase setup (required once)
dart pub global activate flutterfire_cli
flutterfire configure --project=<your-firebase-project-id>

# Run code generation
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

### Cloud Functions Setup

```bash
cd functions
npm install

# Deploy (requires Blaze plan)
firebase deploy --only functions
```

## License

MIT License. See [LICENSE](LICENSE) for details.
