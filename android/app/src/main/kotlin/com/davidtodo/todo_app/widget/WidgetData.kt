package com.davidtodo.todo_app.widget

data class WidgetTask(
    val id: String,
    val title: String,
    val priority: String,
    val dueDate: String?,
    val completed: Boolean
)

data class WidgetData(
    val todayCount: Int,
    val tasks: List<WidgetTask>,
    val lastUpdated: String
) {
    companion object {
        fun empty() = WidgetData(todayCount = 0, tasks = emptyList(), lastUpdated = "")
    }
}
