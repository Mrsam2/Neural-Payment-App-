import 'package:flutter/services.dart';

class NotificationSyncService {
  static const MethodChannel _channel = MethodChannel('com.my_app/notification_sync');

  // Call native method to set the current user ID for the background service
  static Future<void> setUserIdForNative(String? userId) async {
    try {
      await _channel.invokeMethod('setUserId', {'userId': userId});
      print('✅ User ID sent to native service: $userId');
    } on PlatformException catch (e) {
      print("❌ Failed to set user ID for native: '${e.message}'.");
    }
  }

  // Call native method to open notification access settings
  static Future<void> openNotificationSettings() async {
    try {
      await _channel.invokeMethod('openNotificationSettings');
      print('✅ Opened notification settings.');
    } on PlatformException catch (e) {
      print("❌ Failed to open notification settings: '${e.message}'.");
    }
  }

  // Call native method to check if notification service is enabled
  static Future<bool> isNotificationServiceEnabled() async {
    try {
      final bool? isEnabled = await _channel.invokeMethod('isNotificationServiceEnabled');
      print('🔍 Notification service enabled status: $isEnabled');
      return isEnabled ?? false;
    } on PlatformException catch (e) {
      print("❌ Failed to check notification service status: '${e.message}'.");
      return false;
    }
  }
}
