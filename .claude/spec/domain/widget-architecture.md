# 네이티브 위젯 아키텍처 명세

## 1. 개요

Flutter 앱의 태스크 데이터를 네이티브 OS 위젯으로 표시하기 위한 아키텍처를 정의한다.

**지원 플랫폼:** iOS, Android, macOS, Windows

사용자가 앱을 열지 않고도 홈 화면(또는 위젯 보드)에서 오늘의 할 일을 확인하고, 태스크를 완료 처리할 수 있도록 한다.

---

## 2. 위젯 브릿지 패키지

[home_widget](https://pub.dev/packages/home_widget) 패키지를 사용하여 Flutter 앱과 네이티브 위젯 간 데이터를 전달한다.

- Flutter 측에서 `home_widget` API를 통해 공유 저장소에 데이터를 기록한다.
- 네이티브 위젯은 공유 저장소에서 데이터를 읽어 렌더링한다.
- 위젯에서 발생한 사용자 액션은 `home_widget`의 background callback을 통해 Flutter 측으로 전달된다.

---

## 3. 데이터 흐름

```
[Flutter App] -> home_widget API -> [공유 저장소] -> [네이티브 위젯 렌더링]
                                                            |
                                                            v
[Flutter App] <- home_widget background callback <- [사용자 액션]
```

### 3.1 플랫폼별 공유 저장소

| 플랫폼  | 저장소                  | 설정                                                   |
| ------- | ----------------------- | ------------------------------------------------------ |
| iOS     | App Group UserDefaults  | App Group ID 설정 필요                                 |
| macOS   | App Group UserDefaults  | App Group ID 설정 필요                                 |
| Android | SharedPreferences       | `AndroidManifest.xml`에 provider 등록                  |
| Windows | AppData JSON 파일       | 커스텀 플랫폼 채널 (`home_widget` Windows 지원 제한적) |

### 3.2 위젯 데이터 포맷

공유 저장소에 저장되는 JSON 형식은 다음과 같다.

```json
{
  "todayCount": 3,
  "tasks": [
    {
      "id": "uuid-1234",
      "title": "프로젝트 보고서 작성",
      "priority": "high",
      "dueDate": "2026-02-08",
      "completed": false
    },
    {
      "id": "uuid-5678",
      "title": "팀 미팅 준비",
      "priority": "medium",
      "dueDate": "2026-02-08",
      "completed": false
    }
  ],
  "lastUpdated": "2026-02-08T10:30:00"
}
```

**필드 설명:**

| 필드          | 타입     | 설명                                          |
| ------------- | -------- | --------------------------------------------- |
| `todayCount`  | int      | 오늘 마감인 pending 태스크 총 개수            |
| `tasks`       | List     | 우선순위 순으로 정렬된 태스크 목록 (최대 5개) |
| `lastUpdated` | DateTime | 마지막 데이터 갱신 시각 (ISO 8601)            |

---
## 4. 위젯 종류

### 4.1 오늘의 할 일 위젯 (Small)

**목적:** 오늘 마감인 태스크의 개수와 상위 항목을 간략히 보여준다.

| 항목      | 내용                                              |
| --------- | ------------------------------------------------- |
| 크기      | 2x2 (iOS/macOS), Small (Android), Small (Windows) |
| 표시 내용 | 오늘 마감인 pending 태스크 개수 + 상위 3개 제목    |
| 탭 동작   | 앱 홈 화면으로 이동                                |

**레이아웃:**

```
+--------------------+
|  오늘의 할 일       |
|       3개           |
|                     |
|  - 보고서 작성      |
|  - 팀 미팅 준비     |
|  - 코드 리뷰        |
+--------------------+
```

### 4.2 태스크 리스트 위젯 (Medium)

**목적:** pending 태스크를 리스트 형태로 보여주며, 위젯에서 직접 완료 처리가 가능하다.

| 항목      | 내용                                                         |
| --------- | ------------------------------------------------------------ |
| 크기      | 4x2 (iOS/macOS), Medium (Android), Medium (Windows)          |
| 표시 내용 | pending 태스크 리스트 (최대 5개, 우선순위 순)                 |
| 체크박스  | 위젯에서 직접 완료 토글 (`home_widget` background callback)  |
| 탭 동작   | 해당 태스크 상세 화면으로 딥링크                              |

**레이아웃:**

```
+----------------------------------------+
|  할 일 목록                       2/5  |
|                                        |
|  [ ] 프로젝트 보고서 작성      HIGH    |
|  [ ] 팀 미팅 준비              MED     |
|  [ ] 코드 리뷰                MED     |
|  [ ] 장보기                    LOW     |
|  [ ] 운동하기                  LOW     |
+----------------------------------------+
```

---
## 5. 네이티브 구현

### 5.1 iOS / macOS: WidgetKit (SwiftUI)

iOS와 macOS는 모두 WidgetKit 프레임워크를 사용하며, SwiftUI로 위젯 UI를 작성한다. 두 플랫폼의 구현이 거의 동일하므로 코드 공유가 가능하다.

**구성 요소:**

| 요소             | 역할                                       |
| ---------------- | ------------------------------------------ |
| WidgetExtension  | 위젯 타겟 (별도 빌드 타겟으로 추가)        |
| TimelineProvider | 위젯 데이터 갱신 스케줄 관리               |
| App Group        | Flutter 앱과 위젯 Extension 간 데이터 공유 |
| SwiftUI View     | 위젯 UI 렌더링                             |

**설정 항목:**

- Xcode에서 WidgetExtension 타겟 추가
- App Group capability 활성화 (앱 타겟 + 위젯 타겟 모두)
- `home_widget` 패키지의 iOS/macOS 설정에 App Group ID 등록

**파일 위치:**

```
ios/TodoWidget/
  TodoWidget.swift           # Widget 정의 및 TimelineProvider
  TodoWidgetEntryView.swift  # SwiftUI 위젯 뷰
  TodoWidget.intentdefinition
  Info.plist

macos/TodoWidget/
  TodoWidget.swift
  TodoWidgetEntryView.swift
  Info.plist
```

**TimelineProvider 동작:**

```
getTimeline() 호출
  -> App Group UserDefaults에서 JSON 읽기
  -> TimelineEntry 생성
  -> Timeline 반환 (reloadPolicy: .after(15분 후))
```

### 5.2 Android: Jetpack Glance (Compose)

Android에서는 Jetpack Glance를 사용하여 Compose 기반으로 위젯 UI를 작성한다.

**구성 요소:**

| 요소                    | 역할                            |
| ----------------------- | ------------------------------- |
| GlanceAppWidget         | 위젯 UI 정의 (Compose 기반)    |
| GlanceAppWidgetReceiver | 위젯 업데이트 브로드캐스트 수신 |
| SharedPreferences       | Flutter 앱과 데이터 공유        |

**설정 항목:**

- `AndroidManifest.xml`에 위젯 provider 등록
- `res/xml/`에 위젯 메타데이터 정의 (크기, 갱신 주기 등)
- `home_widget` 패키지의 Android 설정 적용

**파일 위치:**

```
android/app/src/main/kotlin/.../widget/
  TodoSmallWidget.kt           # 오늘의 할 일 위젯 (Small)
  TodoListWidget.kt            # 태스크 리스트 위젯 (Medium)
  TodoWidgetReceiver.kt        # 업데이트 수신
  WidgetDataHelper.kt          # SharedPreferences 데이터 파싱

android/app/src/main/res/xml/
  todo_small_widget_info.xml   # Small 위젯 메타데이터
  todo_list_widget_info.xml    # Medium 위젯 메타데이터
```

### 5.3 Windows: Widget Provider

Windows 11의 위젯 보드를 타겟으로 하며, Adaptive Cards 기반으로 구현한다.

**구성 요소:**

| 요소              | 역할                        |
| ----------------- | --------------------------- |
| Widget Provider   | COM 서버로 위젯 데이터 제공 |
| Adaptive Cards    | JSON 기반 위젯 UI 정의     |
| AppData JSON 파일 | Flutter 앱과 데이터 공유    |

**설정 항목:**

- C++/WinRT 또는 C#으로 Widget Provider 구현
- 패키지 매니페스트에 위젯 등록
- `home_widget`의 Windows 지원이 제한적이므로 커스텀 플랫폼 채널 구현 필요

**파일 위치:**

```
windows/widget/
  WidgetProvider.cpp       # Widget Provider COM 서버
  WidgetProvider.h
  AdaptiveCards/
    SmallWidget.json       # Small 위젯 Adaptive Card 템플릿
    ListWidget.json        # Medium 위젯 Adaptive Card 템플릿
  CMakeLists.txt
```

**리스크:**

- Windows 위젯은 가장 복잡한 구현이며, `home_widget` 패키지의 공식 지원이 제한적이다.
- Widget Provider COM 서버 구현, 패키지 매니페스트 설정 등 추가 작업이 많다.
- **막히면 위젯 없이 앱만 출시한다.** Windows 위젯은 선택적 기능으로 취급한다.

---
## 6. Flutter 측 구현

### 6.1 WidgetService

`WidgetService`는 Flutter 앱에서 네이티브 위젯과의 모든 상호작용을 담당하는 서비스 클래스이다.

```dart
class WidgetService {
  /// 위젯 데이터 업데이트
  /// Task 변경(생성, 수정, 삭제, 완료 토글) 시 호출한다.
  /// pending 태스크를 우선순위 순으로 정렬하여 공유 저장소에 기록한다.
  Future<void> updateWidgetData(List<TaskEntity> tasks);

  /// 위젯에서 수신한 액션 처리
  /// 위젯의 체크박스 토글 등 사용자 액션을 처리한다.
  /// home_widget background callback에서 호출된다.
  Future<void> handleWidgetAction(String action, Map<String, dynamic> data);

  /// 위젯 갱신 요청
  /// 네이티브 위젯에 UI 갱신을 트리거한다.
  Future<void> refreshWidget();
}
```

### 6.2 데이터 변환 로직

`updateWidgetData()` 내부에서 수행하는 데이터 변환 순서는 다음과 같다.

1. 전체 태스크 목록에서 `completed == false`인 항목만 필터링한다.
2. 오늘 마감인 태스크 개수를 `todayCount`로 집계한다.
3. 우선순위(high > medium > low) 순으로 정렬한다.
4. 상위 5개 태스크를 JSON으로 직렬화한다.
5. `home_widget` API를 통해 공유 저장소에 기록한다.
6. `refreshWidget()`를 호출하여 위젯 UI 갱신을 트리거한다.

### 6.3 Background Callback 등록

앱 초기화 시 `home_widget`의 background callback을 등록하여 위젯 액션을 수신한다.

```dart
// main.dart 또는 앱 초기화 로직
HomeWidget.registerInteractivityCallback(widgetBackgroundCallback);

@pragma('vm:entry-point')
Future<void> widgetBackgroundCallback(Uri? uri) async {
  if (uri == null) return;

  final action = uri.host;       // 예: 'toggle_complete'
  final taskId = uri.queryParameters['id'];

  // WidgetService.handleWidgetAction() 호출
}
```

---
## 7. 갱신 전략

위젯 데이터의 최신성을 유지하기 위한 갱신 전략을 정의한다.

### 7.1 이벤트 기반 갱신

| 트리거                | 동작                                    |
| --------------------- | --------------------------------------- |
| Task CRUD 수행 시     | `WidgetService.updateWidgetData()` 호출 |
| 앱 포그라운드 진입 시 | `WidgetService.refreshWidget()` 호출    |
| 위젯 체크박스 토글 시 | DB 업데이트 후 `updateWidgetData()` 호출 |

### 7.2 주기적 갱신

| 플랫폼      | 방식                                  | 주기 |
| ----------- | ------------------------------------- | ---- |
| iOS / macOS | `TimelineReloadPolicy.after(date)`    | 15분 |
| Android     | WorkManager 또는 `updatePeriodMillis` | 15분 |
| Windows     | Widget Provider 자체 스케줄           | 15분 |

**참고:** iOS/Android 모두 OS 차원에서 최소 갱신 주기에 제한이 있다. 실제 갱신 간격은 OS 정책에 따라 15분보다 길어질 수 있다.

---

## 8. 딥링크 처리

위젯 탭 시 앱의 특정 화면으로 이동하기 위해 딥링크를 사용한다.

| 위젯 동작             | 딥링크 URI                     | 이동 화면        |
| --------------------- | ------------------------------ | ---------------- |
| Small 위젯 탭         | `todoapp://home`               | 앱 홈 화면       |
| Medium 위젯 태스크 탭 | `todoapp://task?id={taskId}`   | 태스크 상세 화면 |
| Medium 위젯 체크박스  | (background callback으로 처리) | 화면 이동 없음   |

---

## 9. 개발 우선순위

구현 순서는 사용자 수와 구현 난이도를 고려하여 다음과 같이 정한다.

| 순위 | 플랫폼  | 근거                                            |
| ---- | ------- | ----------------------------------------------- |
| 1    | Android | 가장 많은 사용자, Jetpack Glance로 비교적 간단  |
| 2    | iOS     | Apple 생태계, WidgetKit 문서가 잘 정리되어 있음 |
| 3    | macOS   | iOS WidgetKit과 거의 동일한 코드 공유 가능      |
| 4    | Windows | 가장 복잡한 구현, 선택적 기능으로 취급          |

---

## 10. 테스트 전략

### 10.1 Flutter 측

- `WidgetService`의 데이터 변환 로직을 단위 테스트한다.
- `home_widget` API 호출을 mock하여 저장소 기록 여부를 검증한다.
- background callback의 액션 처리를 테스트한다.

### 10.2 네이티브 측

- 각 플랫폼의 위젯 UI를 미리보기(Preview)로 확인한다.
  - iOS/macOS: Xcode Preview
  - Android: Glance의 `@Preview` 어노테이션
- 실제 기기에서 위젯 추가/갱신/액션 동작을 수동 테스트한다.
- 공유 저장소의 데이터 읽기/쓰기를 통합 테스트한다.

---

## 11. 제외 범위

다음 항목은 Phase 4에서 구현하지 않는다.

- 위젯 설정/커스터마이징 UI (필터, 테마 선택 등)
- 카테고리/태그별 위젯 변형
- iOS 잠금 화면 위젯 (`.accessoryRectangular` 등)
- Large 위젯 크기
- Watch/Wearable 위젯
- 위젯 사용 분석/텔레메트리
- 위젯 액션 실패 시 재시도 큐
- Windows 위젯: best-effort (막히면 스킵)
- 다국어 위젯 텍스트 (현재 한국어 고정)

---

## 12. 검증 체크리스트

### 12.1 자동 검증 (Dart)

- [ ] `fvm flutter test` — 전체 Dart 단위 테스트 통과
- [ ] `fvm dart run build_runner build --delete-conflicting-outputs` — 코드 생성 정상
- [ ] `fvm flutter build apk --debug` — Android 빌드 성공
- [ ] `fvm flutter build ios --debug --no-codesign` — iOS 빌드 성공

### 12.2 수동 검증 (플랫폼별)

**Android:**
- [ ] 홈 화면에서 Small 위젯 추가 → 오늘 할 일 개수 + 상위 3개 제목 표시
- [ ] 홈 화면에서 Medium 위젯 추가 → 태스크 리스트 최대 5개 표시
- [ ] 앱에서 Task CRUD → 위젯 자동 업데이트
- [ ] Medium 위젯 체크박스 → 완료 토글 동작
- [ ] Small 위젯 탭 → 앱 홈 화면 이동
- [ ] Medium 위젯 태스크 탭 → 태스크 상세 화면 딥링크

**iOS:**
- [ ] 홈 화면에서 Small 위젯 추가 → 정상 렌더링
- [ ] 홈 화면에서 Medium 위젯 추가 → 정상 렌더링
- [ ] 앱에서 Task CRUD → 위젯 자동 업데이트
- [ ] Medium 위젯 체크박스 → 완료 토글 동작
- [ ] 위젯 탭 → 올바른 화면으로 딥링크

**macOS:**
- [ ] 위젯 갤러리에서 Small/Medium 위젯 추가 → 정상 렌더링
- [ ] 앱에서 Task CRUD → 위젯 자동 업데이트
- [ ] 위젯 탭 → 앱으로 이동

**공통:**
- [ ] 앱 프로세스 종료 후 위젯에 캐시 데이터 표시
- [ ] 앱 포그라운드 진입 시 위젯 갱신
