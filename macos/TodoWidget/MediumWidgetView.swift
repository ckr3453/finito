import SwiftUI
import WidgetKit

struct MediumWidgetView: View {
    let entry: TodoEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Header
            HStack {
                Text("할 일 목록")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Spacer()
                let completedCount = entry.data.tasks.filter { $0.completed }.count
                Text("\(completedCount)/\(entry.data.tasks.count)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            if entry.data.tasks.isEmpty {
                Spacer()
                Text("할 일이 없습니다")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
            } else {
                ForEach(entry.data.tasks.prefix(5)) { task in
                    Link(destination: URL(string: "todoapp://task?id=\(task.id)")!) {
                        TaskRowView(task: task)
                    }
                }
                Spacer()
            }
        }
        .padding(12)
    }
}

struct TaskRowView: View {
    let task: WidgetTask

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: task.completed ? "checkmark.square.fill" : "square")
                .font(.caption)
                .foregroundColor(task.completed ? .green : .secondary)

            Text(task.title)
                .font(.caption)
                .foregroundColor(.primary)
                .lineLimit(1)

            Spacer()

            Text(task.priorityLabel)
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(priorityColor)
        }
    }

    private var priorityColor: Color {
        switch task.priority {
        case "high": return .red
        case "medium": return .orange
        default: return .gray
        }
    }
}
