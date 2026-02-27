# Finito

Cross-platform TODO application with cloud sync and native widgets.

## Tech Stack
- **Framework**: Flutter 3.38+ (Dart)
- **State Management**: Riverpod 2.x (riverpod_annotation + riverpod_generator)
- **Local DB**: Drift (SQLite ORM)
- **Backend**: Firebase (Firestore + Auth + Hosting + Cloud Functions)
- **Routing**: go_router
- **Models**: Freezed + json_serializable
- **Widget Bridge**: home_widget (Android)

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
│   ├── screens/       # home, task_detail, task_editor, categories, search, settings, auth, admin
│   ├── providers/     # Riverpod providers
│   └── shared_widgets/
├── services/          # sync, notification, fcm, widget, connectivity, auth, user
├── routing/           # GoRouter config
functions/             # Firebase Cloud Functions (email reminders)
```

## Git Branching Strategy
- **GitHub Flow**: `master` is always deployable
- Branch from `master`, work, PR, merge back to `master`, delete branch
- Branch naming: `<type>/<short-description>` (e.g., `feat/google-auth`, `fix/task-crash`)
- Never commit directly to `master` — always use feature branches + PR

## Git Commit Convention
- Follow [Conventional Commits](https://www.conventionalcommits.org/)
- Format: `<type>(<scope>): <description>`
- Types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `style`, `perf`, `ci`, `build`
- Subject: English, imperative mood, max 50 chars, no period
- Body (optional): explain **why**, wrap at 72 chars
- Example: `feat(auth): add Google OAuth login`

## Conventions
- Use Freezed for all domain entities
- Use Riverpod annotation style (@riverpod)
- All Drift tables in `data/database/`
- Repository pattern: interface in `domain/repositories/`, implementation in `data/repositories/`
- Code generation: `dart run build_runner build --delete-conflicting-outputs`

## Platforms
- Web, Android, Windows
- Android: app + widget
- Web/Windows: app only
