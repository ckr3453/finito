# Finito

Cross-platform TODO app with cloud sync and native widgets.

## Features

- Task CRUD with title, description, due date, priority
- Categories and tags for organization
- Search and filtering (status, priority, category)
- Drag-and-drop sorting
- Dark mode support
- Responsive layout (mobile / desktop)

## Tech Stack

| Area | Technology |
|------|------------|
| Framework | Flutter 3.38+ (Dart) |
| State Management | Riverpod 2.x |
| Local DB | Drift (SQLite ORM) |
| Backend | Firebase (Firestore + Auth) |
| Routing | GoRouter |
| Models | Freezed + json_serializable |

## Architecture

**Local-First + Cloud-Synced** - UI always reads from local Drift DB. Background sync to Firestore when online.

```
[UI] <--watches--> [Riverpod Providers]
                          |
                     [Repository]
                      /        \
              [Drift DB]    [Firestore]
           (read from here)  (sync when online)
```

## Project Structure

```
lib/
├── core/              # Constants, extensions, theme
├── data/              # Data layer
│   ├── database/      # Drift DB tables, DAOs
│   └── repositories/  # Repository implementations
├── domain/            # Entities (Freezed), enums, repository interfaces
├── presentation/      # UI layer
│   ├── screens/       # home, task_detail, task_editor, categories, search, settings
│   ├── providers/     # Riverpod providers
│   └── shared_widgets/
├── services/          # sync, connectivity
└── routing/           # GoRouter config
```

## Supported Platforms

- iOS
- Android
- macOS
- Windows

## Getting Started

### Prerequisites

- Flutter 3.38+
- Dart 3.10+

### Setup

```bash
# Install dependencies
flutter pub get

# Run code generation
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

## License

This project is for personal use.
