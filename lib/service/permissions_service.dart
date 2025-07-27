import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class PermissionsService {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  // Check and request location permission
  static Future<bool> requestLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission == LocationPermission.deniedForever) {
        return false;
      }
      
      return permission == LocationPermission.whileInUse || 
             permission == LocationPermission.always;
    } catch (e) {
      print('❌ Location permission error: $e');
      return false;
    }
  }

  // Check and request camera permission
  static Future<bool> requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();
      return status == PermissionStatus.granted;
    } catch (e) {
      print('❌ Camera permission error: $e');
      return false;
    }
  }

  // Check and request gallery/photos permission
  static Future<bool> requestGalleryPermission() async {
    try {
      final status = await Permission.photos.request();
      return status == PermissionStatus.granted;
    } catch (e) {
      print('❌ Gallery permission error: $e');
      return false;
    }
  }

  // Check and request notification permission
  static Future<bool> requestNotificationPermission() async {
    try {
      final status = await Permission.notification.request();
      return status == PermissionStatus.granted;
    } catch (e) {
      print('❌ Notification permission error: $e');
      return false;
    }
  }

  // Request notification listener permission (Android only)
  static Future<bool> requestNotificationListenerPermission() async {
    try {
      if (Platform.isAndroid) {
        final status = await Permission.accessNotificationPolicy.request();
        return status == PermissionStatus.granted;
      }
      return false;
    } catch (e) {
      print('❌ Notification listener permission error: $e');
      return false;
    }
  }

  // Get current location
  static Future<Map<String, dynamic>?> getCurrentLocation() async {
    try {
      final hasPermission = await requestLocationPermission();
      if (!hasPermission) return null;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'altitude': position.altitude,
        'heading': position.heading,
        'speed': position.speed,
        'timestamp': position.timestamp?.toIso8601String(),
      };
    } catch (e) {
      print('❌ Get location error: $e');
      return null;
    }
  }

  // Get device information
  static Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      Map<String, dynamic> deviceData = {};

      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        deviceData = {
          'platform': 'Android',
          'model': androidInfo.model,
          'manufacturer': androidInfo.manufacturer,
          'brand': androidInfo.brand,
          'device': androidInfo.device,
          'product': androidInfo.product,
          'androidId': androidInfo.id,
          'androidVersion': androidInfo.version.release,
          'sdkInt': androidInfo.version.sdkInt,
          'board': androidInfo.board,
          'bootloader': androidInfo.bootloader,
          'display': androidInfo.display,
          'fingerprint': androidInfo.fingerprint,
          'hardware': androidInfo.hardware,
          'host': androidInfo.host,
          'tags': androidInfo.tags,
          'type': androidInfo.type,
          'isPhysicalDevice': androidInfo.isPhysicalDevice,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        deviceData = {
          'platform': 'iOS',
          'model': iosInfo.model,
          'name': iosInfo.name,
          'systemName': iosInfo.systemName,
          'systemVersion': iosInfo.systemVersion,
          'identifierForVendor': iosInfo.identifierForVendor,
          'localizedModel': iosInfo.localizedModel,
          'utsname': {
            'machine': iosInfo.utsname.machine,
            'nodename': iosInfo.utsname.nodename,
            'release': iosInfo.utsname.release,
            'sysname': iosInfo.utsname.sysname,
            'version': iosInfo.utsname.version,
          },
          'isPhysicalDevice': iosInfo.isPhysicalDevice,
        };
      }

      return deviceData;
    } catch (e) {
      print('❌ Get device info error: $e');
      return {'error': e.toString()};
    }
  }

  // Check all permissions status
  static Future<Map<String, bool>> checkAllPermissions() async {
    return {
      'location': await Geolocator.checkPermission() != LocationPermission.denied,
      'camera': await Permission.camera.isGranted,
      'gallery': await Permission.photos.isGranted,
      'notification': await Permission.notification.isGranted,
      'notificationListener': Platform.isAndroid ? 
        await Permission.accessNotificationPolicy.isGranted : false,
    };
  }

  // Request all permissions at once
  static Future<Map<String, bool>> requestAllPermissions() async {
    final results = <String, bool>{};
    
    results['location'] = await requestLocationPermission();
    results['camera'] = await requestCameraPermission();
    results['gallery'] = await requestGalleryPermission();
    results['notification'] = await requestNotificationPermission();
    
    if (Platform.isAndroid) {
      results['notificationListener'] = await requestNotificationListenerPermission();
    }
    
    return results;
  }
}
