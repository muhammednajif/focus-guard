package com.example.focus_guard

import android.content.Intent
import android.os.Build
import android.content.pm.PackageManager
import android.content.pm.ResolveInfo
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.util.Base64
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.focus_guard/installed_apps"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getInstalledApps") {
                val apps = getInstalledApps()
                result.success(apps)
            } else if (call.method == "getAppIcon") {
                val packageName = call.argument<String>("packageName")
                if (packageName == null) {
                    result.error("INVALID_ARGUMENT", "packageName is required", null)
                    return@setMethodCallHandler
                }
                result.success(getAppIconBase64(packageName))
            } else if (call.method == "updatePreferences") {
                val args = call.arguments as Map<String, Any>
                val blockedApps = args["blockedApps"] as List<String>
                val blockReels = args["blockReels"] as Boolean
                val blockShorts = args["blockShorts"] as Boolean
                val blockExplore = args["blockExplore"] as? Boolean ?: false

                val prefs = getSharedPreferences("FocusGuardPrefs", android.content.Context.MODE_PRIVATE)
                prefs.edit()
                    .putStringSet("blocked_apps", blockedApps.toSet())
                    .putBoolean("block_reels", blockReels)
                    .putBoolean("block_shorts", blockShorts)
                    .putBoolean("block_explore", blockExplore)
                    .apply()
                result.success(null)
            } else if (call.method == "updateSchedules") {
                val schedules = call.argument<List<Map<String, Any>>>("schedules") ?: emptyList()
                val jsonArray = org.json.JSONArray()
                for (schedule in schedules) {
                    val jsonObj = org.json.JSONObject()
                    for ((key, value) in schedule) {
                        jsonObj.put(key, value)
                    }
                    jsonArray.put(jsonObj)
                }

                val prefs = getSharedPreferences("FocusGuardPrefs", android.content.Context.MODE_PRIVATE)
                prefs.edit().putString("schedules_json", jsonArray.toString()).apply()
                result.success(true)
            } else if (call.method == "updateDailyLimit") {
                val limitHours = call.argument<Double>("limitHours") ?: 0.0
                val prefs = getSharedPreferences("FocusGuardPrefs", android.content.Context.MODE_PRIVATE)
                prefs.edit().putFloat("global_daily_limit_hours", limitHours.toFloat()).apply()
                result.success(true)
            } else if (call.method == "requestUsagePermission") {
                val intent = android.content.Intent(android.provider.Settings.ACTION_USAGE_ACCESS_SETTINGS)
                intent.flags = android.content.Intent.FLAG_ACTIVITY_NEW_TASK
                startActivity(intent)
                result.success(true)
            } else if (call.method == "checkAccessibilityService") {
                val serviceStr = "com.example.focus_guard/com.example.focus_guard.BlockService"
                var isEnabled = false
                val accessibilityEnabled = android.provider.Settings.Secure.getInt(
                    contentResolver,
                    android.provider.Settings.Secure.ACCESSIBILITY_ENABLED, 0
                )
                if (accessibilityEnabled == 1) {
                    val settingValue = android.provider.Settings.Secure.getString(
                        contentResolver,
                        android.provider.Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
                    )
                    if (settingValue != null) {
                        isEnabled = settingValue.contains(serviceStr)
                    }
                }
                result.success(isEnabled)
            } else if (call.method == "openAccessibilitySettings") {
    val intent = android.content.Intent(android.provider.Settings.ACTION_ACCESSIBILITY_SETTINGS)
    intent.flags = android.content.Intent.FLAG_ACTIVITY_NEW_TASK
    startActivity(intent)
    result.success(true)
} else if (call.method == "openBatterySettings") {
    val intent = android.content.Intent(
        android.provider.Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
        android.net.Uri.parse("package:${packageName}")
    )
    intent.flags = android.content.Intent.FLAG_ACTIVITY_NEW_TASK
    startActivity(intent)
    result.success(true)
} else {
    result.notImplemented()
}
        }
    }

    private fun getInstalledApps(): List<Map<String, String>> {
        val pm = packageManager
        val launcherIntent = Intent(Intent.ACTION_MAIN, null).apply {
            addCategory(Intent.CATEGORY_LAUNCHER)
        }

        val resolvedApps: List<ResolveInfo> =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                pm.queryIntentActivities(launcherIntent, PackageManager.ResolveInfoFlags.of(0))
            } else {
                @Suppress("DEPRECATION")
                pm.queryIntentActivities(launcherIntent, 0)
            }

        return resolvedApps
            .mapNotNull { resolveInfo ->
                val activityInfo = resolveInfo.activityInfo ?: return@mapNotNull null
                val packageName = activityInfo.packageName ?: return@mapNotNull null
                val name = resolveInfo.loadLabel(pm)?.toString()?.trim()
                    ?.takeIf { it.isNotEmpty() }
                    ?: packageName

                mapOf(
                    "name" to name,
                    "packageName" to packageName
                )
            }
            .distinctBy { it["packageName"] }
            .sortedBy { it["name"]?.lowercase() }
    }

    private fun getAppIconBase64(packageName: String): String? {
        return try {
            val iconDrawable = packageManager.getApplicationIcon(packageName)
            getIconBase64(iconDrawable)
        } catch (e: Exception) {
            null
        }
    }

    private fun getIconBase64(drawable: Drawable): String? {
        try {
            val bitmap: Bitmap = if (drawable is BitmapDrawable) {
                drawable.bitmap
            } else {
                val width = if (drawable.intrinsicWidth > 0) drawable.intrinsicWidth else 96
                val height = if (drawable.intrinsicHeight > 0) drawable.intrinsicHeight else 96
                val bmp = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
                val canvas = Canvas(bmp)
                drawable.setBounds(0, 0, canvas.width, canvas.height)
                drawable.draw(canvas)
                bmp
            }

            // Scale down to reduce payload size over MethodChannel
            val scaled = Bitmap.createScaledBitmap(bitmap, 96, 96, true)
            val outputStream = ByteArrayOutputStream()
            scaled.compress(Bitmap.CompressFormat.PNG, 100, outputStream)
            return Base64.encodeToString(outputStream.toByteArray(), Base64.NO_WRAP)
        } catch (e: Exception) {
            return null
        }
    }
}
