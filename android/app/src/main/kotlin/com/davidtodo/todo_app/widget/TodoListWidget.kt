package com.davidtodo.todo_app.widget

import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.GlanceTheme
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.action.actionStartActivity
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.layout.Alignment
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.layout.width
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import android.graphics.Color

class TodoListWidget : GlanceAppWidget() {
    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val data = WidgetDataHelper.getWidgetData(context)
        provideContent {
            GlanceTheme {
                ListWidgetContent(context, data)
            }
        }
    }
}

@Composable
private fun ListWidgetContent(context: Context, data: WidgetData) {
    Column(
        modifier = GlanceModifier
            .fillMaxSize()
            .background(ColorProvider(Color.WHITE))
            .padding(12.dp),
    ) {
        // Header
        Row(
            modifier = GlanceModifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Text(
                text = "할 일 목록",
                style = TextStyle(
                    fontSize = 14.sp,
                    fontWeight = FontWeight.Bold,
                    color = ColorProvider(Color.BLACK),
                ),
            )
            Spacer(modifier = GlanceModifier.defaultWeight())
            val completedCount = data.tasks.count { it.completed }
            Text(
                text = "$completedCount/${data.tasks.size}",
                style = TextStyle(
                    fontSize = 12.sp,
                    color = ColorProvider(Color.GRAY),
                ),
            )
        }
        Spacer(modifier = GlanceModifier.height(8.dp))

        // Task list
        data.tasks.take(5).forEach { task ->
            TaskRow(context, task)
            Spacer(modifier = GlanceModifier.height(4.dp))
        }

        if (data.tasks.isEmpty()) {
            Text(
                text = "할 일이 없습니다",
                style = TextStyle(
                    fontSize = 13.sp,
                    color = ColorProvider(Color.GRAY),
                ),
            )
        }
    }
}

@Composable
private fun TaskRow(context: Context, task: WidgetTask) {
    val tapIntent = Intent(Intent.ACTION_VIEW, Uri.parse("todoapp://task?id=${task.id}")).apply {
        setPackage(context.packageName)
    }
    val toggleIntent = Intent(Intent.ACTION_VIEW, Uri.parse("todoapp://toggle_complete?id=${task.id}")).apply {
        setPackage(context.packageName)
    }

    val priorityLabel = when (task.priority) {
        "high" -> "HIGH"
        "medium" -> "MED"
        else -> "LOW"
    }
    val priorityColor = when (task.priority) {
        "high" -> ColorProvider(Color.parseColor("#D32F2F"))
        "medium" -> ColorProvider(Color.parseColor("#F57C00"))
        else -> ColorProvider(Color.GRAY)
    }

    Row(
        modifier = GlanceModifier
            .fillMaxWidth()
            .clickable(actionStartActivity(tapIntent)),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        // Checkbox simulation
        Text(
            text = if (task.completed) "☑" else "☐",
            style = TextStyle(fontSize = 16.sp),
            modifier = GlanceModifier.clickable(actionStartActivity(toggleIntent)),
        )
        Spacer(modifier = GlanceModifier.width(6.dp))
        Text(
            text = task.title,
            style = TextStyle(
                fontSize = 13.sp,
                color = ColorProvider(Color.BLACK),
            ),
            maxLines = 1,
            modifier = GlanceModifier.defaultWeight(),
        )
        Text(
            text = priorityLabel,
            style = TextStyle(
                fontSize = 10.sp,
                fontWeight = FontWeight.Bold,
                color = priorityColor,
            ),
        )
    }
}
