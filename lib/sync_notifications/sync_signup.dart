import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'sync_login_page.dart';

class SyncSignupPage extends StatefulWidget {
  const SyncSignupPage({super.key});

  @override
  State<SyncSignupPage> createState() => _SyncSignupPageState();
}

class _SyncSignupPageState extends State<SyncSignupPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _showPassword = false;
  bool _isLoading = false;
  String _error = '';

  Future<void> _register() async {
    if (_passwordController.text != _confirmController.text) {
      setState(() => _error = "Passwords do not match");
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = userCredential.user;

      if (user != null) {
        await FirebaseFirestore.instance
            .collection("SyncUSER")
            .doc(user.uid)
            .set({
          'uid': user.uid,
          'email': user.email,
          'createdAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration Successful!")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SyncLoginPage()),
        );
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Text("Bridge",
                  style: TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Image.asset("assets/logo.png", height: 60),

              const SizedBox(height: 30),
              _buildInputField("Email", _emailController, false),
              _buildInputField("Password", _passwordController, !_showPassword,
                  toggle: () {
                    setState(() => _showPassword = !_showPassword);
                  }),
              _buildInputField("Confirm Password", _confirmController,
                  !_showPassword, toggle: () {
                    setState(() => _showPassword = !_showPassword);
                  }),

              const SizedBox(height: 10),
              const Text(
                "During the registration process, we will send you an email to verify your account.",
                style: TextStyle(color: Colors.orange),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
              const Text(
                "Make sure you use a valid, accessible email address.",
                style: TextStyle(color: Colors.orange),
                textAlign: TextAlign.center,
              ),

              if (_error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(_error,
                      style: const TextStyle(color: Colors.redAccent)),
                ),

              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: _register,
                child: const Text("REGISTER"),
              ),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already a member? ",
                      style: TextStyle(color: Colors.white70)),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SyncLoginPage()),
                      );
                    },
                    child: const Text(
                      "Login",
                      style: TextStyle(
                          color: Colors.orange, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller,
      bool obscureText,
      {VoidCallback? toggle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.grey[900],
          suffixIcon: toggle != null
              ? IconButton(
            icon: Icon(
                obscureText ? Icons.visibility : Icons.visibility_off,
                color: Colors.white),
            onPressed: toggle,
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
