package com.example.my_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.provider.Settings
import android.content.ComponentName
import android.text.TextUtils

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.yourapp.notifications"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getNotifications" -> {
                    try {
                        val notifications = NotificationService.getNotifications()
                        result.success(notifications)
                    } catch (e: Exception) {
                        result.error("ERROR", "Failed to get notifications", e.message)
                    }
                }
                "clearNotifications" -> {
                    try {
                        NotificationService.clearNotifications()
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("ERROR", "Failed to clear notifications", e.message)
                    }
                }
                "isNotificationServiceEnabled" -> {
                    try {
                        val enabled = isNotificationServiceEnabled()
                        result.success(enabled)
                    } catch (e: Exception) {
                        result.error("ERROR", "Failed to check service status", e.message)
                    }
                }
                "openNotificationSettings" -> {
                    try {
                        openNotificationListenerSettings()
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("ERROR", "Failed to open settings", e.message)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun isNotificationServiceEnabled(): Boolean {
        val packageName = packageName
        val flat = Settings.Secure.getString(contentResolver, "enabled_notification_listeners")
        if (!TextUtils.isEmpty(flat)) {
            val names = flat.split(":").toTypedArray()
            for (name in names) {
                val componentName = ComponentName.unflattenFromString(name)
                if (componentName != null) {
                    if (TextUtils.equals(packageName, componentName.packageName)) {
                        return true
                    }
                }
            }
        }
        return false
    }

    private fun openNotificationListenerSettings() {
        val intent = Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)
        startActivity(intent)
    }
}
