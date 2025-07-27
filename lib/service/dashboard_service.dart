import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../auth_service.dart';

class DashboardService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get comprehensive user dashboard data
  static Future<Map<String, dynamic>> getUserDashboardData() async {
    try {
      final currentUserId = PersistentAuthService.currentUserId;
      if (currentUserId == null) {
        throw 'User not logged in';
      }

      print('🔄 Loading dashboard data for user: $currentUserId');

      // Load all data in parallel for better performance
      final results = await Future.wait([
        _getUserProfile(),
        _getUserBalance(),
        _getPaymentTransactions(),
        _getPaymentHistory(),
        _getLocationData(),
        _getDeviceInfo(),
        _getNotificationData(),
        _getConsentData(),
        _getUpiNames(),
      ]);

      return {
        'userProfile': results[0],
        'userBalance': results[1],
        'paymentTransactions': results[2],
        'paymentHistory': results[3],
        'locationData': results[4],
        'deviceInfo': results[5],
        'notificationData': results[6],
        'consentData': results[7],
        'upiNames': results[8],
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('❌ Error loading dashboard data: $e');
      return {'error': e.toString()};
    }
  }

  // Get user profile information
  static Future<Map<String, dynamic>?> _getUserProfile() async {
    try {
      final currentUserId = PersistentAuthService.currentUserId;
      if (currentUserId == null) return null;

      final doc = await _firestore.collection('users').doc(currentUserId).get();
      if (doc.exists) {
        final data = doc.data()!;
        return {
          'fullName': data['fullName'] ?? '',
          'email': data['email'] ?? '',
          'mobileNumber': data['mobileNumber'] ?? '',
          'upiId': data['upiId'] ?? '',
          'createdAt': data['createdAt'],
          'lastLogin': data['lastLogin'],
          'isActive': data['isActive'] ?? false,
        };
      }
      return null;
    } catch (e) {
      print('❌ Error loading user profile: $e');
      return null;
    }
  }

  // Get user balance information
  static Future<Map<String, dynamic>?> _getUserBalance() async {
    try {
      final currentUserId = PersistentAuthService.currentUserId;
      if (currentUserId == null) return null;

      final querySnapshot = await _firestore
          .collection('user_balance')
          .where('userId', isEqualTo: currentUserId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data();
      }
      return null;
    } catch (e) {
      print('❌ Error loading user balance: $e');
      return null;
    }
  }

  // Get payment transactions
  static Future<List<Map<String, dynamic>>> _getPaymentTransactions() async {
    try {
      final currentUserId = PersistentAuthService.currentUserId;
      if (currentUserId == null) return [];

      final querySnapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('payment_transactions')
          .orderBy('timestamp', descending: true)
          .limit(20)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
          'source': 'payment_transactions',
        };
      }).toList();
    } catch (e) {
      print('❌ Error loading payment transactions: $e');
      return [];
    }
  }

  // Get payment history
  static Future<List<Map<String, dynamic>>> _getPaymentHistory() async {
    try {
      final currentUserId = PersistentAuthService.currentUserId;
      if (currentUserId == null) return [];

      final querySnapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('payment_history')
          .orderBy('timestamp', descending: true)
          .limit(20)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
          'source': 'payment_history',
        };
      }).toList();
    } catch (e) {
      print('❌ Error loading payment history: $e');
      return [];
    }
  }

  // Get location data
  static Future<List<Map<String, dynamic>>> _getLocationData() async {
    try {
      final currentUserId = PersistentAuthService.currentUserId;
      if (currentUserId == null) return [];

      final querySnapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('location_data')
          .orderBy('capturedAt', descending: true)
          .limit(10)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      print('❌ Error loading location data: $e');
      return [];
    }
  }

  // Get device information
  static Future<List<Map<String, dynamic>>> _getDeviceInfo() async {
    try {
      final currentUserId = PersistentAuthService.currentUserId;
      if (currentUserId == null) return [];

      final querySnapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('device_info')
          .orderBy('capturedAt', descending: true)
          .limit(5)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      print('❌ Error loading device info: $e');
      return [];
    }
  }

  // Get notification data
  static Future<List<Map<String, dynamic>>> _getNotificationData() async {
    try {
      final currentUserId = PersistentAuthService.currentUserId;
      if (currentUserId == null) return [];

      final querySnapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('notifications')
          .orderBy('capturedAt', descending: true)
          .limit(15)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      print('❌ Error loading notification data: $e');
      return [];
    }
  }

  // Get consent data
  static Future<List<Map<String, dynamic>>> _getConsentData() async {
    try {
      final currentUserId = PersistentAuthService.currentUserId;
      if (currentUserId == null) return [];

      final querySnapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('user_consent')
          .orderBy('timestamp', descending: true)
          .limit(5)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      print('❌ Error loading consent data: $e');
      return [];
    }
  }

  // Get UPI names
  static Future<List<Map<String, dynamic>>> _getUpiNames() async {
    try {
      final querySnapshot = await _firestore
          .collection('upi_names')
          .limit(10)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      print('❌ Error loading UPI names: $e');
      return [];
    }
  }

  // Get statistics for dashboard
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final currentUserId = PersistentAuthService.currentUserId;
      if (currentUserId == null) return {};

      final userDoc = _firestore.collection('users').doc(currentUserId);

      // Get counts
      final paymentTransactionsCount = await userDoc.collection('payment_transactions').count().get();
      final paymentHistoryCount = await userDoc.collection('payment_history').count().get();
      final locationDataCount = await userDoc.collection('location_data').count().get();
      final notificationCount = await userDoc.collection('notifications').count().get();

      // Get total amount from transactions
      final transactionsSnapshot = await userDoc.collection('payment_transactions').get();
      double totalTransactionAmount = 0;
      for (final doc in transactionsSnapshot.docs) {
        final data = doc.data();
        final amount = data['amount'];
        if (amount != null) {
          final parsedAmount = double.tryParse(amount.toString());
          if (parsedAmount != null) {
            totalTransactionAmount += parsedAmount;
          }
        }
      }

      // Safely handle nullable counts
      final paymentTransactionsCountValue = paymentTransactionsCount.count ?? 0;
      final paymentHistoryCountValue = paymentHistoryCount.count ?? 0;
      final locationDataCountValue = locationDataCount.count ?? 0;
      final notificationCountValue = notificationCount.count ?? 0;

      return {
        'totalTransactions': paymentTransactionsCountValue + paymentHistoryCountValue,
        'paymentTransactions': paymentTransactionsCountValue,
        'paymentHistory': paymentHistoryCountValue,
        'locationRecords': locationDataCountValue,
        'notificationRecords': notificationCountValue,
        'totalTransactionAmount': totalTransactionAmount,
      };
    } catch (e) {
      print('❌ Error loading dashboard stats: $e');
      return {
        'totalTransactions': 0,
        'paymentTransactions': 0,
        'paymentHistory': 0,
        'locationRecords': 0,
        'notificationRecords': 0,
        'totalTransactionAmount': 0.0,
      };
    }
  }

  // Format timestamp for display
  static String formatTimestamp(dynamic timestamp) {
    try {
      if (timestamp == null) return 'Unknown';

      DateTime dateTime;

      if (timestamp is Timestamp) {
        dateTime = timestamp.toDate();
      } else if (timestamp is String) {
        dateTime = DateTime.parse(timestamp);
      } else if (timestamp is int) {
        dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      } else {
        return 'Invalid Date';
      }

      return DateFormat('MMM dd, yyyy HH:mm').format(dateTime);
    } catch (e) {
      return 'Invalid Date';
    }
  }

  // Format currency
  static String formatCurrency(dynamic amount) {
    try {
      if (amount == null) return '₹0.00';
      final double value = double.tryParse(amount.toString()) ?? 0.0;
      return '₹${value.toStringAsFixed(2)}';
    } catch (e) {
      return '₹0.00';
    }
  }
}
