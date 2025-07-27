import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class FirebaseBalanceService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String BALANCE_COLLECTION = 'user_balance';
  static const String USER_ID = 'user_main';
  static const double MONTHLY_BALANCE = 5000.0;

  // Initialize or update monthly balance
  static Future<void> initializeMonthlyBalance() async {
    try {
      final now = DateTime.now();
      final currentMonth = DateFormat('yyyy-MM').format(now);
      
      final balanceDoc = await _firestore
          .collection(BALANCE_COLLECTION)
          .doc(USER_ID)
          .get();

      if (!balanceDoc.exists) {
        // First time setup
        await _firestore.collection(BALANCE_COLLECTION).doc(USER_ID).set({
          'currentBalance': MONTHLY_BALANCE,
          'lastUpdatedMonth': currentMonth,
          'totalSpent': 0.0,
          'lastUpdated': FieldValue.serverTimestamp(),
          'transactionHistory': [],
        });
        print('Balance initialized for first time: ₹$MONTHLY_BALANCE');
      } else {
        // Check if we need to reset for new month
        final data = balanceDoc.data()!;
        final lastUpdatedMonth = data['lastUpdatedMonth'] as String?;
        
        if (lastUpdatedMonth != currentMonth) {
          // New month - reset balance
          await _firestore.collection(BALANCE_COLLECTION).doc(USER_ID).update({
            'currentBalance': MONTHLY_BALANCE,
            'lastUpdatedMonth': currentMonth,
            'totalSpent': 0.0,
            'lastUpdated': FieldValue.serverTimestamp(),
          });
          print('Monthly balance reset to ₹$MONTHLY_BALANCE for $currentMonth');
        }
      }
    } catch (e) {
      print('Error initializing monthly balance: $e');
      throw e;
    }
  }

  // Get current balance
  static Future<Map<String, dynamic>> getCurrentBalance() async {
    try {
      // First ensure monthly balance is initialized
      await initializeMonthlyBalance();
      
      final balanceDoc = await _firestore
          .collection(BALANCE_COLLECTION)
          .doc(USER_ID)
          .get();

      if (balanceDoc.exists) {
        final data = balanceDoc.data()!;
        return {
          'currentBalance': data['currentBalance'] ?? MONTHLY_BALANCE,
          'totalSpent': data['totalSpent'] ?? 0.0,
          'lastUpdatedMonth': data['lastUpdatedMonth'],
          'lastUpdated': data['lastUpdated'],
        };
      } else {
        return {
          'currentBalance': MONTHLY_BALANCE,
          'totalSpent': 0.0,
          'lastUpdatedMonth': DateFormat('yyyy-MM').format(DateTime.now()),
          'lastUpdated': Timestamp.now(),
        };
      }
    } catch (e) {
      print('Error getting current balance: $e');
      throw e;
    }
  }

  // Deduct amount from balance (called after successful payment)
  static Future<Map<String, dynamic>> deductFromBalance({
    required double amount,
    required String transactionId,
    required String merchantName,
    required String upiId,
  }) async {
    try {
      // Get current balance first
      final currentBalanceData = await getCurrentBalance();
      final currentBalance = currentBalanceData['currentBalance'] as double;
      final totalSpent = currentBalanceData['totalSpent'] as double;

      if (currentBalance < amount) {
        throw Exception('Insufficient balance. Available: ₹$currentBalance, Required: ₹$amount');
      }

      final newBalance = currentBalance - amount;
      final newTotalSpent = totalSpent + amount;
      final now = DateTime.now();

      // Create transaction record
      final transactionRecord = {
        'transactionId': transactionId,
        'amount': amount,
        'merchantName': merchantName,
        'upiId': upiId,
        'timestamp': FieldValue.serverTimestamp(),
        'date': DateFormat('dd-MMM-yy').format(now),
        'type': 'debit',
      };

      // Update balance and add transaction
      await _firestore.collection(BALANCE_COLLECTION).doc(USER_ID).update({
        'currentBalance': newBalance,
        'totalSpent': newTotalSpent,
        'lastUpdated': FieldValue.serverTimestamp(),
        'transactionHistory': FieldValue.arrayUnion([transactionRecord]),
      });

      print('Balance updated: ₹$currentBalance -> ₹$newBalance (Spent: ₹$amount)');

      return {
        'previousBalance': currentBalance,
        'newBalance': newBalance,
        'amountDeducted': amount,
        'totalSpent': newTotalSpent,
        'success': true,
      };
    } catch (e) {
      print('Error deducting from balance: $e');
      throw e;
    }
  }

  // Check if sufficient balance is available
  static Future<bool> hasSufficientBalance(double amount) async {
    try {
      final balanceData = await getCurrentBalance();
      final currentBalance = balanceData['currentBalance'] as double;
      return currentBalance >= amount;
    } catch (e) {
      print('Error checking balance: $e');
      return false;
    }
  }
}
