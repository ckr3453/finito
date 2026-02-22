package com.davidtodo.todo_app.widget

import android.content.Context
import android.content.SharedPreferences
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken

object WidgetDataHelper {
    private const val PREFS_NAME = "HomeWidgetPreferences"
    private const val WIDGET_DATA_KEY = "widget_data"

    private val gson = Gson()

    fun getWidgetData(context: Context): WidgetData {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val json = prefs.getString(WIDGET_DATA_KEY, null) ?: return WidgetData.empty()
        return try {
            gson.fromJson(json, WidgetData::class.java) ?: WidgetData.empty()
        } catch (e: Exception) {
            WidgetData.empty()
        }
    }
}
