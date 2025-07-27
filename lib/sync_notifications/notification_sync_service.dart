import 'package:flutter/services.dart';
import 'package:flutter/material.dart'; // For SnackBar

class NotificationSyncService {
  static const MethodChannel _channel = MethodChannel('com.my_app/notification_sync');

  // Call this after a user logs in to set the user ID in the native service
  static Future<void> setUserIdForNative(String? userId) async {
    try {
      await _channel.invokeMethod('setUserId', {'userId': userId});
      print('✅ Native NotificationListener user ID set to: $userId');
    } on PlatformException catch (e) {
      print("❌ Failed to set user ID on native side: '${e.message}'.");
    }
  }

  // Opens the Android Notification Listener settings page
  static Future<void> openNotificationAccessSettings() async {
    try {
      await _channel.invokeMethod('openNotificationSettings');
      print('🔄 Opened notification access settings.');
    } on PlatformException catch (e) {
      print("❌ Failed to open notification settings: '${e.message}'.");
    }
  }

  // Checks if the notification listener service is enabled
  static Future<bool> isNotificationServiceEnabled() async {
    try {
      final bool? isEnabled = await _channel.invokeMethod('isNotificationServiceEnabled');
      print('🔍 Notification service enabled: $isEnabled');
      return isEnabled ?? false;
    } on PlatformException catch (e) {
      print("❌ Failed to check notification service status: '${e.message}'.");
      return false;
    }
  }

  // Helper to show a snackbar message
  static void showSnackBar(BuildContext context, String message, {Color color = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }
}
