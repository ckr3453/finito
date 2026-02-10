import SwiftUI
import WidgetKit

struct SmallWidgetView: View {
    let entry: TodoEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("오늘의 할 일")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.primary)

            Text("\(entry.data.todayCount)개")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.blue)

            Spacer().frame(height: 2)

            ForEach(entry.data.tasks.prefix(3)) { task in
                Text("· \(task.title)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()
        }
        .padding(12)
        .widgetURL(URL(string: "todoapp://home"))
    }
}
