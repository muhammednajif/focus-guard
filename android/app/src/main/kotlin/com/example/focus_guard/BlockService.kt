package com.example.focus_guard

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.content.Intent
import android.content.SharedPreferences
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo

class BlockService : AccessibilityService() {
    private lateinit var prefs: SharedPreferences
    private var lastBlockedPackage: String? = null
    private var lastBlockedAtMillis: Long = 0L

    override fun onServiceConnected() {
        super.onServiceConnected()
        prefs = getSharedPreferences("FocusGuardPrefs", MODE_PRIVATE)
        val info = AccessibilityServiceInfo()
        info.eventTypes = AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED or AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED
        info.feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
        info.flags =
            AccessibilityServiceInfo.FLAG_INCLUDE_NOT_IMPORTANT_VIEWS or AccessibilityServiceInfo.FLAG_RETRIEVE_INTERACTIVE_WINDOWS
        info.notificationTimeout = 100
        serviceInfo = info
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return
        if (!isScheduleActive()) return

        val packageName = event.packageName?.toString() ?: return
        if (packageName == applicationContext.packageName) return

        val tempUnlockTime = prefs.getLong("temp_unlock_$packageName", 0L)
        if (System.currentTimeMillis() < tempUnlockTime) {
            return
        }

        val blockedApps = prefs.getStringSet("blocked_apps", emptySet()) ?: emptySet()
        val isBlockedApp = blockedApps.contains(packageName)

        var shouldBlock = false
        if (isBlockedApp) {
            shouldBlock = true
        }

        if (shouldBlock) {
            showBlockOverlay(packageName)
        }
    }

    private fun showBlockOverlay(packageName: String) {
        val now = System.currentTimeMillis()
        if (lastBlockedPackage == packageName && now - lastBlockedAtMillis < 1500L) return

        lastBlockedPackage = packageName
        lastBlockedAtMillis = now

        val intent = Intent(this, BlockOverlayActivity::class.java)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        intent.putExtra("blocked_package", packageName)
        startActivity(intent)
    }

    private fun isScheduleActive(): Boolean {
        val jsonStr = prefs.getString("schedules_json", "[]")
        if (jsonStr == "[]" || jsonStr.isNullOrEmpty()) return true

        try {
            val jsonArray = org.json.JSONArray(jsonStr)
            val cal = java.util.Calendar.getInstance()
            val currentHour = cal.get(java.util.Calendar.HOUR_OF_DAY)
            val currentMinute = cal.get(java.util.Calendar.MINUTE)
            val currentTotalMinutes = currentHour * 60 + currentMinute

            var hasEnabledSchedule = false
            for (i in 0 until jsonArray.length()) {
                val obj = jsonArray.getJSONObject(i)
                if (obj.optBoolean("enabled", false)) {
                    hasEnabledSchedule = true
                    val startTotal = obj.optInt("startHour", 0) * 60 + obj.optInt("startMinute", 0)
                    val endTotal = obj.optInt("endHour", 23) * 60 + obj.optInt("endMinute", 59)

                    if (startTotal <= endTotal) {
                        if (currentTotalMinutes in startTotal..endTotal) return true
                    } else {
                        if (currentTotalMinutes >= startTotal || currentTotalMinutes <= endTotal) return true
                    }
                }
            }
            return !hasEnabledSchedule
        } catch (e: Exception) {
            return true
        }
    }

    private fun hasExceededDailyLimit(packageName: String): Boolean {
        val limitHours = prefs.getFloat("global_daily_limit_hours", 0f)
        if (limitHours <= 0f) return false

        val limitMillis = (limitHours * 60 * 60 * 1000).toLong()
        val usm = getSystemService(android.content.Context.USAGE_STATS_SERVICE) as android.app.usage.UsageStatsManager
        val cal = java.util.Calendar.getInstance()
        cal.set(java.util.Calendar.HOUR_OF_DAY, 0)
        cal.set(java.util.Calendar.MINUTE, 0)
        cal.set(java.util.Calendar.SECOND, 0)
        cal.set(java.util.Calendar.MILLISECOND, 0)
        val startTime = cal.timeInMillis
        val endTime = System.currentTimeMillis()

        val stats = usm.queryUsageStats(android.app.usage.UsageStatsManager.INTERVAL_DAILY, startTime, endTime)
        if (stats == null || stats.isEmpty()) return false

        var totalTime = 0L
        for (usageStats in stats) {
            if (usageStats.packageName == packageName) {
                totalTime += usageStats.totalTimeInForeground
            }
        }
        return totalTime >= limitMillis
    }

    override fun onInterrupt() {}
}
