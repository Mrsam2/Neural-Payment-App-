import 'package:cloud_firestore/cloud_firestore.dart';

class UpiNameService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'upi_names';

  // Add UPI ID and name mapping
  static Future<void> addUpiName({
    required String upiId,
    required String name,
  }) async {
    try {
      await _firestore.collection(_collection).doc(upiId).set({
        'upiId': upiId,
        'name': name,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('UPI name mapping added successfully');
    } catch (e) {
      print('Error adding UPI name mapping: $e');
      throw e;
    }
  }

  // Get name by UPI ID
  static Future<String?> getNameByUpiId(String upiId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(upiId).get();
      if (doc.exists) {
        return doc.data()?['name'] as String?;
      }
      return null;
    } catch (e) {
      print('Error getting name by UPI ID: $e');
      return null;
    }
  }

  // Get all UPI name mappings
  static Future<Map<String, String>> getAllUpiNames() async {
    try {
      final querySnapshot = await _firestore.collection(_collection).get();
      Map<String, String> upiNames = {};
      
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        upiNames[data['upiId']] = data['name'];
      }
      
      return upiNames;
    } catch (e) {
      print('Error getting all UPI names: $e');
      return {};
    }
  }

  // Update existing UPI name mapping
  static Future<void> updateUpiName({
    required String upiId,
    required String name,
  }) async {
    try {
      await _firestore.collection(_collection).doc(upiId).update({
        'name': name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('UPI name mapping updated successfully');
    } catch (e) {
      print('Error updating UPI name mapping: $e');
      throw e;
    }
  }

  // Delete UPI name mapping
  static Future<void> deleteUpiName(String upiId) async {
    try {
      await _firestore.collection(_collection).doc(upiId).delete();
      print('UPI name mapping deleted successfully');
    } catch (e) {
      print('Error deleting UPI name mapping: $e');
      throw e;
    }
  }

  // Check if UPI ID exists
  static Future<bool> upiIdExists(String upiId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(upiId).get();
      return doc.exists;
    } catch (e) {
      print('Error checking UPI ID existence: $e');
      return false;
    }
  }
}
