import WidgetKit

struct TodoEntry: TimelineEntry {
    let date: Date
    let data: WidgetData
}

struct TodoTimelineProvider: TimelineProvider {
    private let appGroupId = "group.com.davidtodo.todoapp"

    func placeholder(in context: Context) -> TodoEntry {
        TodoEntry(date: Date(), data: .preview)
    }

    func getSnapshot(in context: Context, completion: @escaping (TodoEntry) -> Void) {
        if context.isPreview {
            completion(TodoEntry(date: Date(), data: .preview))
        } else {
            let data = WidgetData.load(appGroupId: appGroupId)
            completion(TodoEntry(date: Date(), data: data))
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TodoEntry>) -> Void) {
        let data = WidgetData.load(appGroupId: appGroupId)
        let entry = TodoEntry(date: Date(), data: data)
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}
