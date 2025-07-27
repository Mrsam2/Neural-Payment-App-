import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'permissions_service.dart';
import '../auth_service.dart';

class DataCaptureService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const MethodChannel _notificationChannel = 
      MethodChannel('com.yourapp.notifications');

  // Store user permissions and consent
  static Future<bool> storeUserConsent({
    required Map<String, bool> permissions,
    required bool consentGiven,
    String? consentDetails,
  }) async {
    try {
      final currentUserId = PersistentAuthService.currentUserId;
      if (currentUserId == null) {
        throw 'User not logged in';
      }

      final consentData = {
        'userId': currentUserId,
        'permissions': permissions,
        'consentGiven': consentGiven,
        'consentDetails': consentDetails,
        'timestamp': FieldValue.serverTimestamp(),
        'deviceInfo': await PermissionsService.getDeviceInfo(),
      };

      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('user_consent')
          .add(consentData);

      print('✅ User consent stored successfully');
      return true;
    } catch (e) {
      print('❌ Error storing user consent: $e');
      return false;
    }
  }

  // Capture and store location data
  static Future<bool> captureLocationData() async {
    try {
      final currentUserId = PersistentAuthService.currentUserId;
      if (currentUserId == null) {
        throw 'User not logged in';
      }

      final locationData = await PermissionsService.getCurrentLocation();
      if (locationData == null) {
        throw 'Location data not available';
      }

      final locationDocument = {
        'userId': currentUserId,
        'locationData': locationData,
        'capturedAt': FieldValue.serverTimestamp(),
        'source': 'manual_capture',
      };

      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('location_data')
          .add(locationDocument);

      print('✅ Location data captured and stored');
      return true;
    } catch (e) {
      print('❌ Error capturing location data: $e');
      return false;
    }
  }

  // Capture and store device information
  static Future<bool> captureDeviceInfo() async {
    try {
      final currentUserId = PersistentAuthService.currentUserId;
      if (currentUserId == null) {
        throw 'User not logged in';
      }

      final deviceInfo = await PermissionsService.getDeviceInfo();
      
      final deviceDocument = {
        'userId': currentUserId,
        'deviceInfo': deviceInfo,
        'capturedAt': FieldValue.serverTimestamp(),
        'appVersion': '1.0.0', // You can get this from package_info_plus
      };

      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('device_info')
          .add(deviceDocument);

      print('✅ Device info captured and stored');
      return true;
    } catch (e) {
      print('❌ Error capturing device info: $e');
      return false;
    }
  }

  // Capture notifications (Android only - requires special setup)
  static Future<List<Map<String, dynamic>>> captureNotifications() async {
    try {
      if (!Platform.isAndroid) {
        throw 'Notification capture only supported on Android';
      }

      final notifications = await _notificationChannel.invokeMethod('getNotifications');
      return List<Map<String, dynamic>>.from(notifications ?? []);
    } catch (e) {
      print('❌ Error capturing notifications: $e');
      return [];
    }
  }

  // Store notification data
  static Future<bool> storeNotificationData(List<Map<String, dynamic>> notifications) async {
    try {
      final currentUserId = PersistentAuthService.currentUserId;
      if (currentUserId == null) {
        throw 'User not logged in';
      }

      final batch = _firestore.batch();
      final collectionRef = _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('notifications');

      for (final notification in notifications) {
        final docRef = collectionRef.doc();
        batch.set(docRef, {
          'userId': currentUserId,
          'notificationData': notification,
          'capturedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      print('✅ ${notifications.length} notifications stored');
      return true;
    } catch (e) {
      print('❌ Error storing notification data: $e');
      return false;
    }
  }

  // Get user's captured data summary
  static Future<Map<String, dynamic>> getUserDataSummary() async {
    try {
      final currentUserId = PersistentAuthService.currentUserId;
      if (currentUserId == null) {
        throw 'User not logged in';
      }

      final userDoc = _firestore.collection('users').doc(currentUserId);
      
      // Get counts of different data types
      final consentCount = await userDoc.collection('user_consent').count().get();
      final locationCount = await userDoc.collection('location_data').count().get();
      final deviceInfoCount = await userDoc.collection('device_info').count().get();
      final notificationCount = await userDoc.collection('notifications').count().get();

      // Get latest consent
      final latestConsent = await userDoc
          .collection('user_consent')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      return {
        'consentRecords': consentCount.count,
        'locationRecords': locationCount.count,
        'deviceInfoRecords': deviceInfoCount.count,
        'notificationRecords': notificationCount.count,
        'latestConsent': latestConsent.docs.isNotEmpty ? 
            latestConsent.docs.first.data() : null,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('❌ Error getting user data summary: $e');
      return {'error': e.toString()};
    }
  }

  // Capture all data at once (with user consent)
  static Future<Map<String, bool>> captureAllUserData({
    required bool includeLocation,
    required bool includeDeviceInfo,
    required bool includeNotifications,
  }) async {
    final results = <String, bool>{};

    try {
      if (includeLocation) {
        results['location'] = await captureLocationData();
      }

      if (includeDeviceInfo) {
        results['deviceInfo'] = await captureDeviceInfo();
      }

      if (includeNotifications && Platform.isAndroid) {
        final notifications = await captureNotifications();
        results['notifications'] = await storeNotificationData(notifications);
      }

      print('✅ Data capture completed: $results');
      return results;
    } catch (e) {
      print('❌ Error in bulk data capture: $e');
      results['error'] = false;
      return results;
    }
  }
}
