package com.example.my_app

import android.content.Context
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.os.Bundle
import android.app.Notification

class NotificationService : NotificationListenerService() {
    companion object {
        private var notifications = mutableListOf<Map<String, Any>>()
        
        fun getNotifications(): List<Map<String, Any>> {
            return notifications.toList()
        }
        
        fun clearNotifications() {
            notifications.clear()
        }
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        super.onNotificationPosted(sbn)
        
        sbn?.let { notification ->
            try {
                val extras: Bundle = notification.notification.extras
                
                val notificationData = mapOf(
                    "packageName" to notification.packageName,
                    "postTime" to notification.postTime,
                    "id" to notification.id,
                    "tag" to (notification.tag ?: ""),
                    "key" to notification.key,
                    "title" to (extras.getString(Notification.EXTRA_TITLE) ?: ""),
                    "text" to (extras.getString(Notification.EXTRA_TEXT) ?: ""),
                    "subText" to (extras.getString(Notification.EXTRA_SUB_TEXT) ?: ""),
                    "bigText" to (extras.getString(Notification.EXTRA_BIG_TEXT) ?: ""),
                    "timestamp" to System.currentTimeMillis()
                )
                
                notifications.add(notificationData)
                
                // Keep only last 100 notifications to prevent memory issues
                if (notifications.size > 100) {
                    notifications.removeAt(0)
                }
            } catch (e: Exception) {
                // Handle any exceptions silently
                e.printStackTrace()
            }
        }
    }

    override fun onNotificationRemoved(sbn: StatusBarNotification?) {
        super.onNotificationRemoved(sbn)
        // Handle notification removal if needed
    }

    override fun onListenerConnected() {
        super.onListenerConnected()
        // Called when the notification listener is connected
    }

    override fun onListenerDisconnected() {
        super.onListenerDisconnected()
        // Called when the notification listener is disconnected
    }
}
