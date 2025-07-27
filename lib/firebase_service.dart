import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'auth_service.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Store payment transaction for specific user
  static Future<String> storePaymentTransaction({
    required String title,
    required String upiId,
    required String amount,
    required String bankName,
    required String accountNumber,
  }) async {
    try {
      // Get current user ID
      final currentUserId = PersistentAuthService.currentUserId;
      if (currentUserId == null) {
        throw 'User not logged in';
      }

      print('🔄 Storing payment transaction for user: $currentUserId');

      // Generate transaction ID
      final random = Random();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final transactionId = 'Tx$timestamp${random.nextInt(9999).toString().padLeft(4, '0')}';

      final transactionData = {
        'userId': currentUserId, // Associate with current user
        'title': title,
        'upiId': upiId,
        'amount': amount,
        'bankName': bankName,
        'accountNumber': accountNumber,
        'transactionId': transactionId,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'Success',
        'type': 'paid_to',
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Store in user-specific subcollection
      final docRef = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('payment_transactions')
          .add(transactionData);

      // Also store in global collection for admin purposes (optional)
      await _firestore
          .collection('payment_transactions')
          .doc(docRef.id)
          .set({
        ...transactionData,
        'documentId': docRef.id,
      });

      print('✅ Payment transaction stored with ID: ${docRef.id}');
      return docRef.id;

    } catch (e) {
      print('❌ Error storing payment transaction: $e');
      throw 'Failed to store transaction: $e';
    }
  }

  // Store custom payment history for specific user
  static Future<String> storePaymentHistory({
    required String name,
    required String upiId,
    required String amount,
    required String type,
    String? prepaidReferenceId,
  }) async {
    try {
      // Get current user ID
      final currentUserId = PersistentAuthService.currentUserId;
      if (currentUserId == null) {
        throw 'User not logged in';
      }

      print('🔄 Storing payment history for user: $currentUserId');

      // Generate transaction ID
      final random = Random();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final transactionId = 'Tx$timestamp${random.nextInt(9999).toString().padLeft(4, '0')}';

      final historyData = {
        'userId': currentUserId, // Associate with current user
        'name': name,
        'upi_id': upiId,
        'amount': amount,
        'type': type,
        'transaction_id': transactionId,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'Success',
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Add prepaid reference ID if provided
      if (prepaidReferenceId != null) {
        historyData['prepaid_reference_id'] = prepaidReferenceId;
      }

      // Store in user-specific subcollection
      final docRef = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('payment_history')
          .add(historyData);

      // Also store in global collection for admin purposes (optional)
      await _firestore
          .collection('payment_history')
          .doc(docRef.id)
          .set({
        ...historyData,
        'documentId': docRef.id,
      });

      print('✅ Payment history stored with ID: ${docRef.id}');
      return docRef.id;

    } catch (e) {
      print('❌ Error storing payment history: $e');
      throw 'Failed to store payment history: $e';
    }
  }

  // Get user-specific payment transactions
  static Future<List<Map<String, dynamic>>> getUserPaymentTransactions() async {
    try {
      final currentUserId = PersistentAuthService.currentUserId;
      if (currentUserId == null) {
        print('❌ User not logged in');
        return [];
      }

      print('🔄 Loading payment transactions for user: $currentUserId');

      final querySnapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('payment_transactions')
          .orderBy('timestamp', descending: true)
          .get();

      List<Map<String, dynamic>> transactions = [];
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        transactions.add({
          ...data,
          'id': doc.id,
          'source': 'payment',
        });
      }

      print('✅ Loaded ${transactions.length} payment transactions');
      return transactions;

    } catch (e) {
      print('❌ Error loading user payment transactions: $e');
      return [];
    }
  }

  // Get user-specific payment history
  static Future<List<Map<String, dynamic>>> getUserPaymentHistory() async {
    try {
      final currentUserId = PersistentAuthService.currentUserId;
      if (currentUserId == null) {
        print('❌ User not logged in');
        return [];
      }

      print('🔄 Loading payment history for user: $currentUserId');

      final querySnapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('payment_history')
          .orderBy('timestamp', descending: true)
          .get();

      List<Map<String, dynamic>> history = [];
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        history.add({
          ...data,
          'id': doc.id,
          'source': 'history',
        });
      }

      print('✅ Loaded ${history.length} payment history entries');
      return history;

    } catch (e) {
      print('❌ Error loading user payment history: $e');
      return [];
    }
  }

  // Get all user transactions (both payment transactions and history)
  static Future<List<Map<String, dynamic>>> getAllUserTransactions() async {
    try {
      final currentUserId = PersistentAuthService.currentUserId;
      if (currentUserId == null) {
        print('❌ User not logged in');
        return [];
      }

      print('🔄 Loading all transactions for user: $currentUserId');

      // Load both payment transactions and history
      final paymentTransactions = await getUserPaymentTransactions();
      final paymentHistory = await getUserPaymentHistory();

      // Combine and sort by timestamp
      List<Map<String, dynamic>> allTransactions = [
        ...paymentTransactions,
        ...paymentHistory,
      ];

      // Sort by timestamp
      allTransactions.sort((a, b) {
        final aTime = _getTimestampAsDateTime(a['timestamp']);
        final bTime = _getTimestampAsDateTime(b['timestamp']);

        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;

        return bTime.compareTo(aTime);
      });

      print('✅ Loaded ${allTransactions.length} total transactions');
      return allTransactions;

    } catch (e) {
      print('❌ Error loading all user transactions: $e');
      return [];
    }
  }

  // Helper method to safely convert timestamp to DateTime
  static DateTime? _getTimestampAsDateTime(dynamic timestamp) {
    if (timestamp == null) return null;

    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is String) {
      try {
        return DateTime.parse(timestamp);
      } catch (e) {
        return null;
      }
    } else if (timestamp is int) {
      try {
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      } catch (e) {
        return null;
      }
    }

    return null;
  }

  // Get specific transaction by ID for current user
  static Future<Map<String, dynamic>?> getUserTransaction(String transactionId) async {
    try {
      final currentUserId = PersistentAuthService.currentUserId;
      if (currentUserId == null) {
        print('❌ User not logged in');
        return null;
      }

      print('🔄 Loading transaction $transactionId for user: $currentUserId');

      // Try payment_transactions first
      try {
        final doc = await _firestore
            .collection('users')
            .doc(currentUserId)
            .collection('payment_transactions')
            .doc(transactionId)
            .get();

        if (doc.exists) {
          final data = doc.data()!;
          return {
            ...data,
            'id': doc.id,
            'source': 'payment',
          };
        }
      } catch (e) {
        print('Transaction not found in payment_transactions: $e');
      }

      // Try payment_history
      try {
        final doc = await _firestore
            .collection('users')
            .doc(currentUserId)
            .collection('payment_history')
            .doc(transactionId)
            .get();

        if (doc.exists) {
          final data = doc.data()!;
          return {
            ...data,
            'id': doc.id,
            'source': 'history',
          };
        }
      } catch (e) {
        print('Transaction not found in payment_history: $e');
      }

      print('❌ Transaction not found: $transactionId');
      return null;

    } catch (e) {
      print('❌ Error loading user transaction: $e');
      return null;
    }
  }

  static Future getPaymentTransaction(String transactionDocumentId) async {}
}
