import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'login_page.dart';
import 'secure_pin_screen.dart';
import 'home_page.dart';
import 'secure_pin_service.dart';

class AuthWrapper extends StatefulWidget {
  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      print('🔄 Initializing authentication...');

      // Initialize persistent auth service
      await PersistentAuthService.initialize();

      // Add a small delay to ensure everything is ready
      await Future.delayed(Duration(milliseconds: 200));

      // Check if user has valid session
      final hasValidSession = await PersistentAuthService.hasValidSession();

      print('🔍 Session check result: $hasValidSession');
      print('🔍 isLoggedIn getter: ${PersistentAuthService.isLoggedIn}');

      setState(() {
        _isLoggedIn = hasValidSession;
        _isLoading = false;
      });

      if (hasValidSession) {
        print('✅ User has valid session, staying logged in');
      } else {
        print('❌ No valid session found, showing login');
      }

    } catch (e) {
      print('❌ Auth initialization error: $e');
      setState(() {
        _isLoggedIn = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.purple),
              SizedBox(height: 16),
              Text(
                'Loading...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoggedIn) {
      // User is logged in, check secure PIN
      return FutureBuilder<bool>(
        future: SecurePinService.isSecurePinVerified(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.purple),
                    SizedBox(height: 16),
                    Text(
                      'Checking security...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            );
          }

          if (snapshot.data == true) {
            return HomePage();
          } else {
            return SecurePinScreen();
          }
        },
      );
    } else {
      return LoginPage();
    }
  }
}
