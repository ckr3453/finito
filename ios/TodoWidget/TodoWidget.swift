import WidgetKit
import SwiftUI

struct TodoSmallWidget: Widget {
    let kind: String = "TodoSmallWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TodoTimelineProvider()) { entry in
            SmallWidgetView(entry: entry)
        }
        .configurationDisplayName("오늘의 할 일")
        .description("오늘 마감인 할 일 개수와 목록을 보여줍니다.")
        .supportedFamilies([.systemSmall])
    }
}

struct TodoListWidget: Widget {
    let kind: String = "TodoListWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TodoTimelineProvider()) { entry in
            MediumWidgetView(entry: entry)
        }
        .configurationDisplayName("할 일 목록")
        .description("할 일 목록을 보여주고 완료 처리할 수 있습니다.")
        .supportedFamilies([.systemMedium])
    }
}

@main
struct TodoWidgetBundle: WidgetBundle {
    var body: some Widget {
        TodoSmallWidget()
        TodoListWidget()
    }
}
