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
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import android.graphics.Color

class TodoSmallWidget : GlanceAppWidget() {
    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val data = WidgetDataHelper.getWidgetData(context)
        provideContent {
            GlanceTheme {
                SmallWidgetContent(context, data)
            }
        }
    }
}

@Composable
private fun SmallWidgetContent(context: Context, data: WidgetData) {
    val intent = Intent(Intent.ACTION_VIEW, Uri.parse("todoapp://home")).apply {
        setPackage(context.packageName)
    }

    Column(
        modifier = GlanceModifier
            .fillMaxSize()
            .background(ColorProvider(Color.WHITE))
            .padding(12.dp)
            .clickable(actionStartActivity(intent)),
        verticalAlignment = Alignment.Top,
        horizontalAlignment = Alignment.Start,
    ) {
        Text(
            text = "오늘의 할 일",
            style = TextStyle(
                fontSize = 14.sp,
                fontWeight = FontWeight.Bold,
                color = ColorProvider(Color.BLACK),
            ),
        )
        Text(
            text = "${data.todayCount}개",
            style = TextStyle(
                fontSize = 28.sp,
                fontWeight = FontWeight.Bold,
                color = ColorProvider(Color.parseColor("#1976D2")),
            ),
        )
        Spacer(modifier = GlanceModifier.height(4.dp))
        data.tasks.take(3).forEach { task ->
            Text(
                text = "· ${task.title}",
                style = TextStyle(
                    fontSize = 12.sp,
                    color = ColorProvider(Color.DKGRAY),
                ),
                maxLines = 1,
            )
        }
    }
}
