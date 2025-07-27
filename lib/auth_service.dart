import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class PersistentAuthService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Current user session data
  static Map<String, dynamic>? _currentUser;
  static String? _sessionToken;

  // Storage keys
  static const String _sessionTokenKey = 'auth_session_token';
  static const String _userDataKey = 'auth_user_data';
  static const String _isLoggedInKey = 'is_logged_in';

  // Check if user is logged in
  static bool get isLoggedIn => _currentUser != null && _sessionToken != null;

  // Get current user data
  static Map<String, dynamic>? get currentUser => _currentUser;

  // Get current user ID
  static String? get currentUserId => _currentUser?['uid'];

  // Hash PIN for security
  static String _hashPin(String pin) {
    var bytes = utf8.encode(pin);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Generate session token
  static String _generateSessionToken() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final random = DateTime.now().microsecondsSinceEpoch.toString();
    var bytes = utf8.encode('$timestamp$random');
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Convert user data for storage (simplified - no Timestamp issues)
  static Map<String, dynamic> _prepareUserDataForStorage(Map<String, dynamic> userData) {
    final storageData = Map<String, dynamic>.from(userData);

    try {
      // Convert any Timestamps to milliseconds
      storageData.forEach((key, value) {
        if (value is Timestamp) {
          storageData[key] = value.millisecondsSinceEpoch;
        }
      });

      // Remove any non-serializable objects
      storageData.removeWhere((key, value) => value is FieldValue);

      print('🔍 Prepared storage data for: ${storageData['fullName']}');
      return storageData;
    } catch (e) {
      print('❌ Error preparing user data: $e');
      // Return minimal safe version
      return {
        'uid': userData['uid'],
        'fullName': userData['fullName'],
        'mobileNumber': userData['mobileNumber'],
        'upiId': userData['upiId'],
        'email': userData['email'],
        'isActive': userData['isActive'],
        'authType': userData['authType'],
        'sessionToken': userData['sessionToken'],
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'lastLogin': DateTime.now().millisecondsSinceEpoch,
      };
    }
  }

  // Save session to local storage
  static Future<void> _saveSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      print('🔄 Saving session...');

      if (_sessionToken != null && _currentUser != null) {
        // Save session token
        final tokenSaved = await prefs.setString(_sessionTokenKey, _sessionToken!);
        print('✅ Token saved: $tokenSaved');

        // Save user data
        final storageData = _prepareUserDataForStorage(_currentUser!);
        final jsonString = jsonEncode(storageData);
        final userDataSaved = await prefs.setString(_userDataKey, jsonString);
        print('✅ User data saved: $userDataSaved');

        // Save login flag
        final flagSaved = await prefs.setBool(_isLoggedInKey, true);
        print('✅ Login flag saved: $flagSaved');

        // Verify data was saved
        final verifyToken = prefs.getString(_sessionTokenKey);
        final verifyUserData = prefs.getString(_userDataKey);
        final verifyFlag = prefs.getBool(_isLoggedInKey);

        print('🔍 Verification - Token: ${verifyToken != null}, UserData: ${verifyUserData != null}, Flag: $verifyFlag');

        if (verifyToken != null && verifyUserData != null && verifyFlag == true) {
          print('✅ Session successfully saved and verified!');
        } else {
          print('❌ Session save verification failed!');
        }
      }
    } catch (e) {
      print('❌ Error saving session: $e');
    }
  }

  // Load session from local storage
  static Future<void> _loadSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      print('🔄 Loading session...');

      final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
      print('🔍 Login flag: $isLoggedIn');

      if (isLoggedIn) {
        _sessionToken = prefs.getString(_sessionTokenKey);
        final userDataString = prefs.getString(_userDataKey);

        print('🔍 Token found: ${_sessionToken != null}');
        print('🔍 User data found: ${userDataString != null}');

        if (_sessionToken != null && userDataString != null) {
          try {
            final storageData = Map<String, dynamic>.from(jsonDecode(userDataString));

            // Convert milliseconds back to Timestamps if needed
            storageData.forEach((key, value) {
              if (key.contains('At') && value is int) {
                storageData[key] = Timestamp.fromMillisecondsSinceEpoch(value);
              }
            });

            _currentUser = storageData;
            print('✅ Session loaded for user: ${_currentUser!['fullName']}');
          } catch (e) {
            print('❌ Error parsing user data: $e');
            await _clearSession();
          }
        } else {
          print('❌ Incomplete session data');
          await _clearSession();
        }
      } else {
        print('🔍 No login flag found');
      }
    } catch (e) {
      print('❌ Error loading session: $e');
      await _clearSession();
    }
  }

  // Clear session
  static Future<void> _clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove(_sessionTokenKey);
      await prefs.remove(_userDataKey);
      await prefs.remove(_isLoggedInKey);

      _currentUser = null;
      _sessionToken = null;

      print('✅ Session cleared');
    } catch (e) {
      print('❌ Error clearing session: $e');
    }
  }

  // Initialize auth service
  static Future<void> initialize() async {
    print('🔄 Initializing Persistent Auth Service...');
    await _loadSession();
    print('✅ Persistent Auth Service initialized');
    print('🔍 Current state - isLoggedIn: $isLoggedIn, user: ${_currentUser?['fullName'] ?? 'none'}');
  }

  // Sign up with persistent authentication
  static Future<bool> signUp({
    required String fullName,
    required String mobileNumber,
    required String upiId,
    required String email,
    required String pin,
  }) async {
    try {
      print('🚀 Starting signup process...');

      // Generate unique user ID
      final userId = _firestore.collection('users').doc().id;
      final sessionToken = _generateSessionToken();

      // Create user document for Firestore
      final firestoreUserData = {
        'uid': userId,
        'fullName': fullName,
        'mobileNumber': mobileNumber,
        'upiId': upiId,
        'email': email,
        'pin': _hashPin(pin),
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
        'isActive': true,
        'authType': 'persistent',
        'sessionToken': sessionToken,
      };

      // Save to Firestore
      await _firestore.collection('users').doc(userId).set(firestoreUserData);
      print('✅ User data saved to Firestore');

      // Create user data for local storage
      final localUserData = {
        'uid': userId,
        'fullName': fullName,
        'mobileNumber': mobileNumber,
        'upiId': upiId,
        'email': email,
        'pin': _hashPin(pin),
        'createdAt': Timestamp.now(),
        'lastLogin': Timestamp.now(),
        'isActive': true,
        'authType': 'persistent',
        'sessionToken': sessionToken,
      };

      // Set current user session
      _currentUser = localUserData;
      _sessionToken = sessionToken;

      // Save session to local storage
      await _saveSession();

      print('✅ Signup completed successfully!');
      return true;

    } catch (e) {
      print('❌ Signup error: $e');
      throw 'Account creation failed: $e';
    }
  }

  // Sign in with persistent authentication
  static Future<bool> signIn({
    required String email,
    required String pin,
  }) async {
    try {
      print('🔐 Starting sign in process for: $email');

      // Find user by email
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw 'No account found with this email address.';
      }

      final userDoc = querySnapshot.docs.first;
      final userData = userDoc.data();
      final storedHashedPin = userData['pin'];
      final hashedInputPin = _hashPin(pin);

      if (storedHashedPin != hashedInputPin) {
        throw 'Invalid PIN. Please try again.';
      }

      // Generate new session token
      final sessionToken = _generateSessionToken();

      // Update last login and session token in Firestore
      await _firestore.collection('users').doc(userDoc.id).update({
        'lastLogin': FieldValue.serverTimestamp(),
        'sessionToken': sessionToken,
      });

      // Set current user session with updated data
      userData['sessionToken'] = sessionToken;
      userData['lastLogin'] = Timestamp.now();
      _currentUser = userData;
      _sessionToken = sessionToken;

      // Save session to local storage
      await _saveSession();

      print('✅ Sign in successful for: ${userData['fullName']}');
      return true;

    } catch (e) {
      print('❌ Sign in error: $e');
      if (e.toString().contains('Invalid PIN') || e.toString().contains('No account found')) {
        rethrow;
      }
      throw 'Login failed. Please try again.';
    }
  }

  // Sign out
  static Future<void> signOut() async {
    try {
      print('🔄 Starting sign out process...');

      // Clear session token from Firestore if user exists
      if (_currentUser != null && _currentUser!['uid'] != null) {
        await _firestore.collection('users').doc(_currentUser!['uid']).update({
          'sessionToken': null,
        });
        print('✅ Session token cleared from server');
      }

      // Clear local session
      await _clearSession();

      print('👋 Sign out successful');
    } catch (e) {
      print('❌ Error during sign out: $e');
      // Clear local session even if Firestore update fails
      await _clearSession();
    }
  }

  // Check if user has valid session (for app startup)
  static Future<bool> hasValidSession() async {
    try {
      print('🔍 Checking if user has valid session...');

      // If we have session data loaded, consider it valid
      if (isLoggedIn) {
        print('✅ Session data found locally');
        return true;
      }

      print('❌ No session data found');
      return false;
    } catch (e) {
      print('❌ Error checking valid session: $e');
      return false;
    }
  }

  // Get user data
  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      if (_currentUser == null) {
        print('❌ No current user session');
        return null;
      }

      print('✅ Returning user data for: ${_currentUser!['fullName']}');
      return _currentUser;

    } catch (e) {
      print('❌ Error getting user data: $e');
      return _currentUser;
    }
  }

  // Check if email exists
  static Future<bool> emailExists(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('❌ Error checking email existence: $e');
      return false;
    }
  }

  // Check if UPI ID exists
  static Future<bool> upiIdExists(String upiId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('upiId', isEqualTo: upiId)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('❌ Error checking UPI ID existence: $e');
      return false;
    }
  }

  // Check if mobile number exists
  static Future<bool> mobileExists(String mobile) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('mobileNumber', isEqualTo: mobile)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('❌ Error checking mobile existence: $e');
      return false;
    }
  }
}
