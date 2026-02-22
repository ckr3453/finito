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

    static func load(appGroupId: String) -> WidgetData {
        guard let defaults = UserDefaults(suiteName: appGroupId),
              let jsonString = defaults.string(forKey: "widget_data"),
              let data = jsonString.data(using: .utf8) else {
            return .empty
        }
        do {
            return try JSONDecoder().decode(WidgetData.self, from: data)
        } catch {
            return .empty
        }
    }
}
