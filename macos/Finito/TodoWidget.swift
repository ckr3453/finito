import WidgetKit
import SwiftUI

struct SmallTodoWidget: Widget {
    let kind: String = "SmallTodoWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TodoTimelineProvider()) { entry in
            SmallWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("오늘의 할 일")
        .description("오늘 할 일 개수와 목록을 보여줍니다")
        .supportedFamilies([.systemSmall])
    }
}

struct MediumTodoWidget: Widget {
    let kind: String = "MediumTodoWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TodoTimelineProvider()) { entry in
            MediumWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("할 일 목록")
        .description("할 일 목록과 진행 상황을 보여줍니다")
        .supportedFamilies([.systemMedium])
    }
}
