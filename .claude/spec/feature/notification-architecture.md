# Notification Architecture

## Overview
Local reminder notifications + FCM token management for future server push.

## Scope
- **In**: Local reminders (timezone-aware scheduled), FCM token storage, notification tap navigation, reminder CRUD UI
- **Out**: Server-side FCM sending (Cloud Functions — future)

## Data Model
- `TaskEntity.reminderTime`: `DateTime?` — nullable, UTC
- Drift `TaskItems.reminderTime`: `DateTimeColumn.nullable()`
- Schema v3 migration from v2

## Notification ID Strategy
- `taskId.hashCode` → deterministic int mapping, no lookup table needed

## Android Channels
- `task_reminders` (HIGH): local reminders
- `fcm_default` (DEFAULT): FCM push

## Scheduling
- `timezone` package + `zonedSchedule` API
- `AndroidScheduleMode.exactAllowWhileIdle` for Doze mode
- App startup: reschedule all future reminders (reboot recovery)

## Auto-Reschedule
- `reminderAutoRescheduleProvider` watches `watchAllTasks` stream
- Pattern: same as `widgetAutoUpdateProvider`

## Service Architecture
```
lib/services/notification/
  notification.dart                    # barrel
  notification_service.dart            # abstract interface
  notification_service_impl.dart       # implementation
  local_notification_client.dart       # plugin abstraction
  local_notification_client_impl.dart  # FlutterLocalNotificationsPlugin wrapper
  fcm_client.dart                      # FCM abstraction
  fcm_client_impl.dart                 # FirebaseMessaging wrapper
  fcm_service.dart                     # FCM service interface
  fcm_service_impl.dart                # FCM service implementation
```

## Testability
- Abstract client interfaces for plugins (same pattern as HomeWidgetClient)
- Pure logic testable via mock clients
- Integration tests with mock notification client
