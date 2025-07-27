import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseConfig {
  static Future<void> initialize() async {
    try {
      // Initialize Firebase
      await Firebase.initializeApp();
      
      // Configure Firebase Auth settings (REMOVE FOR PRODUCTION)
      // await FirebaseAuth.instance.useAuthEmulator('localhost', 9099); 
      
      // Configure Firestore settings
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      
      print('✅ Firebase initialized successfully');
    } catch (e) {
      print('❌ Firebase initialization error: $e');
      rethrow;
    }
  }
  
  // This method is redundant if initialize() is called once at app start.
  // Keeping it for reference but it's not used in the main flow.
  static Future<void> initializeForProduction() async {
    try {
      await Firebase.initializeApp();
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      print('✅ Firebase initialized for production');
    } catch (e) {
      print('❌ Firebase initialization error: $e');
      rethrow;
    }
  }
}
