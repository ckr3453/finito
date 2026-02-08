# TODO App

Cross-platform TODO application with cloud sync and native widgets.

## Tech Stack
- **Framework**: Flutter 3.38+ (Dart)
- **State Management**: Riverpod 2.x (riverpod_annotation + riverpod_generator)
- **Local DB**: Drift (SQLite ORM)
- **Backend**: Firebase (Firestore + Auth + FCM)
- **Routing**: go_router
- **Models**: Freezed + json_serializable
- **Widget Bridge**: home_widget

## Architecture
- **Local-First + Cloud-Synced**: UI reads from Drift, background sync to Firestore
- **Conflict Resolution**: Last-Write-Wins (updatedAt)

## Project Structure
```
lib/
├── core/              # Constants, extensions, theme, utils
├── data/              # Data layer
│   ├── database/      # Drift DB tables, DAOs
│   ├── models/        # Firestore DTOs
│   ├── datasources/   # local/ + remote/
│   └── repositories/  # Local+remote combined
├── domain/            # Entities (Freezed), enums, repository interfaces
├── presentation/      # UI layer
│   ├── screens/       # home, task_detail, task_editor, categories, search, settings, auth
│   ├── providers/     # Riverpod providers
│   └── shared_widgets/
├── services/          # sync, notification, fcm, widget, connectivity
└── routing/           # GoRouter config
```

## Conventions
- Use Freezed for all domain entities
- Use Riverpod annotation style (@riverpod)
- All Drift tables in `data/database/`
- Repository pattern: interface in `domain/repositories/`, implementation in `data/repositories/`
- Code generation: `dart run build_runner build --delete-conflicting-outputs`

## Platforms
- iOS, Android, macOS, Windows + native widgets for each
