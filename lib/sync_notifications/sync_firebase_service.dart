import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SyncFirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // User Authentication
  Future<UserCredential> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw e; // Re-throw to be caught by UI
    }
  }

  Future<UserCredential> signUp(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Create a user document in Firestore
      await _firestore.collection('sync_users').doc(userCredential.user!.uid).set({
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw e;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Device Management
  Future<void> addDevice(String userId, String deviceName, String deviceId) async {
    await _firestore
        .collection('sync_users')
        .doc(userId)
        .collection('devices')
        .doc(deviceId)
        .set({
      'name': deviceName,
      'deviceId': deviceId,
      'addedAt': FieldValue.serverTimestamp(),
      'lastActive': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getDevices(String userId) {
    return _firestore
        .collection('sync_users')
        .doc(userId)
        .collection('devices')
        .snapshots();
  }

  Future<void> updateDeviceLastActive(String userId, String deviceId) async {
    await _firestore
        .collection('sync_users')
        .doc(userId)
        .collection('devices')
        .doc(deviceId)
        .update({
      'lastActive': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteDevice(String userId, String deviceId) async {
    await _firestore
        .collection('sync_users')
        .doc(userId)
        .collection('devices')
        .doc(deviceId)
        .delete();
  }

  // Notification Syncing (Basic Placeholder)
  Future<void> saveNotification(String userId, String deviceId, Map<String, dynamic> notificationData) async {
    await _firestore
        .collection('sync_users')
        .doc(userId)
        .collection('devices')
        .doc(deviceId)
        .collection('notifications')
        .add({
      ...notificationData,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getNotifications(String userId, String deviceId) {
    return _firestore
        .collection('sync_users')
        .doc(userId)
        .collection('devices')
        .doc(deviceId)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
