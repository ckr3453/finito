import Foundation

struct WidgetTask: Codable, Identifiable {
    let id: String
    let title: String
    let priority: String
    let dueDate: String?
    let completed: Bool

    var priorityLabel: String {
        switch priority {
        case "high": return "HIGH"
        case "medium": return "MED"
        default: return "LOW"
        }
    }
}

struct WidgetData: Codable {
    let todayCount: Int
    let tasks: [WidgetTask]
    let lastUpdated: String

    static let empty = WidgetData(todayCount: 0, tasks: [], lastUpdated: "")

    static let preview = WidgetData(
        todayCount: 3,
        tasks: [
            WidgetTask(id: "1", title: "Flutter 위젯 연동", priority: "high", dueDate: nil, completed: false),
            WidgetTask(id: "2", title: "UI 테스트 작성", priority: "medium", dueDate: nil, completed: false),
            WidgetTask(id: "3", title: "코드 리뷰", priority: "low", dueDate: nil, completed: true),
        ],
        lastUpdated: ""
    )

    static func load(appGroupId: String) -> WidgetData {
        // Try App Group UserDefaults first
        if let defaults = UserDefaults(suiteName: appGroupId),
           let jsonString = defaults.string(forKey: "widget_data"),
           let data = jsonString.data(using: .utf8),
           let decoded = try? JSONDecoder().decode(WidgetData.self, from: data) {
            return decoded
        }
        // Fallback to standard UserDefaults
        if let jsonString = UserDefaults.standard.string(forKey: "widget_data"),
           let data = jsonString.data(using: .utf8),
           let decoded = try? JSONDecoder().decode(WidgetData.self, from: data) {
            return decoded
        }
        return .empty
    }
}
