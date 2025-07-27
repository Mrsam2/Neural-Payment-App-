import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'auth_service.dart';
import 'signup_page.dart';
import 'home_page.dart';
import 'dart:math' as math;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _pinController = TextEditingController();

  bool _isLoading = false;
  bool _isPinVisible = false;

  late AnimationController _glowController;
  late AnimationController _pulseController;
  late AnimationController _scanController;
  late AnimationController _matrixController;
  late AnimationController _circuitController;
  late Animation<double> _glowAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scanAnimation;
  late Animation<double> _matrixAnimation;
  late Animation<double> _circuitAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scanController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _matrixController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );
    _circuitController = AnimationController(
      duration: const Duration(milliseconds: 5000),
      vsync: this,
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.linear),
    );
    _matrixAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _matrixController, curve: Curves.linear),
    );
    _circuitAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _circuitController, curve: Curves.linear),
    );

    _glowController.repeat(reverse: true);
    _pulseController.repeat(reverse: true);
    _scanController.repeat();
    _matrixController.repeat();
    _circuitController.repeat();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _pinController.dispose();
    _glowController.dispose();
    _pulseController.dispose();
    _scanController.dispose();
    _matrixController.dispose();
    _circuitController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // Add haptic feedback
    HapticFeedback.mediumImpact();

    try {
      await PersistentAuthService.signIn(
        email: _emailController.text.trim(),
        pin: _pinController.text.trim(),
      );

      if (mounted) {
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.black),
                SizedBox(width: 8),
                Text('Neural authentication successful!'),
              ],
            ),
            backgroundColor: const Color(0xFF00FF00),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
              (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Expanded(child: Text('Neural authentication failed: $e')),
              ],
            ),
            backgroundColor: const Color(0xFFFF0040),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Stack(
          children: [
            // Animated background matrix effect
            _buildMatrixBackground(),
            // Circuit pattern overlay
            _buildCircuitPattern(),
            // Main content
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF1A1A2E),
                    Color(0xFF16213E),
                    Color(0xFF0A0A0A),
                  ],
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 60),
                      _buildEnhancedCyberpunkHeader(),
                      const SizedBox(height: 60),
                      _buildEmailField(),
                      const SizedBox(height: 24),
                      _buildPinField(),
                      const SizedBox(height: 40),
                      _buildEnhancedLoginButton(),
                      const SizedBox(height: 24),
                      _buildBiometricOption(),
                      const SizedBox(height: 24),
                      _buildSignupLink(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatrixBackground() {
    return AnimatedBuilder(
      animation: _matrixAnimation,
      builder: (context, child) => Positioned.fill(
        child: CustomPaint(
          painter: MatrixPainter(_matrixAnimation.value),
        ),
      ),
    );
  }

  Widget _buildCircuitPattern() {
    return AnimatedBuilder(
      animation: _circuitAnimation,
      builder: (context, child) => Positioned.fill(
        child: CustomPaint(
          painter: CircuitPainter(_circuitAnimation.value),
        ),
      ),
    );
  }

  Widget _buildEnhancedCyberpunkHeader() {
    return Column(
      children: [
        // Holographic login icon with multiple layers
        Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow ring
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) => Transform.scale(
                scale: _pulseAnimation.value * 1.5,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF00FFFF).withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
            // Middle ring
            AnimatedBuilder(
              animation: _scanAnimation,
              builder: (context, child) => Transform.rotate(
                angle: _scanAnimation.value * 2 * math.pi,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFF00FF).withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
            // Main icon container
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) => Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF00FFFF).withOpacity(0.8),
                        const Color(0xFFFF00FF).withOpacity(0.6),
                        const Color(0xFF0080FF).withOpacity(0.4),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.3, 0.6, 1.0],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: AnimatedBuilder(
                    animation: _glowAnimation,
                    builder: (context, child) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color.lerp(const Color(0xFF00FFFF), const Color(0xFFFF00FF), _glowAnimation.value)!,
                            Color.lerp(const Color(0xFFFF00FF), const Color(0xFF00FFFF), _glowAnimation.value)!,
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color.lerp(const Color(0xFF00FFFF), const Color(0xFFFF00FF), _glowAnimation.value)!.withOpacity(0.8),
                            blurRadius: 40,
                            spreadRadius: 15,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.security,
                        color: Colors.black,
                        size: 60,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        // Enhanced title with glitch effect
        AnimatedBuilder(
          animation: _scanAnimation,
          builder: (context, child) => ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                Color.lerp(const Color(0xFF00FFFF), const Color(0xFFFF00FF), _scanAnimation.value)!,
                Color.lerp(const Color(0xFFFF00FF), const Color(0xFF00FFFF), _scanAnimation.value)!,
              ],
            ).createShader(bounds),
            child: const Text(
              'NEURAL ACCESS TERMINAL',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Animated subtitle
        AnimatedBuilder(
          animation: _matrixAnimation,
          builder: (context, child) => Text(
            'AUTHENTICATE TO QUANTUM NETWORK',
            style: TextStyle(
              color: Color.lerp(const Color(0xFF808080), const Color(0xFF00FFFF), _matrixAnimation.value)!,
              fontSize: 14,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Status indicator
        AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1A1A2E).withOpacity(0.8),
                  const Color(0xFF16213E).withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF00FF00).withOpacity(0.8),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00FF00),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00FF00).withOpacity(0.8),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'SYSTEM ONLINE',
                  style: TextStyle(
                    color: Color(0xFF00FF00),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return _buildEnhancedCyberpunkTextField(
      controller: _emailController,
      label: 'NEURAL EMAIL ADDRESS',
      hint: 'Enter your neural email',
      icon: Icons.email,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Neural email address required';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Invalid neural email format';
        }
        return null;
      },
    );
  }

  Widget _buildPinField() {
    return _buildEnhancedCyberpunkTextField(
      controller: _pinController,
      label: 'QUANTUM ACCESS PIN',
      hint: 'Enter your 4-digit PIN',
      icon: Icons.lock,
      obscureText: !_isPinVisible,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4),
      ],
      suffixIcon: IconButton(
        icon: AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) => Icon(
            _isPinVisible ? Icons.visibility : Icons.visibility_off,
            color: Color.lerp(const Color(0xFF00FFFF), const Color(0xFFFF00FF), _glowAnimation.value)!,
          ),
        ),
        onPressed: () {
          setState(() {
            _isPinVisible = !_isPinVisible;
          });
          HapticFeedback.lightImpact();
        },
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Quantum access PIN required';
        }
        if (value.trim().length != 4) {
          return 'PIN must be exactly 4 digits';
        }
        return null;
      },
    );
  }

  Widget _buildEnhancedLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.lerp(const Color(0xFF00FFFF), const Color(0xFFFF00FF), _glowAnimation.value)!,
                Color.lerp(const Color(0xFFFF00FF), const Color(0xFF00FFFF), _glowAnimation.value)!,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Color.lerp(const Color(0xFF00FFFF), const Color(0xFFFF00FF), _glowAnimation.value)!.withOpacity(0.8),
                blurRadius: 25,
                spreadRadius: 3,
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _login,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isLoading
                ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.black,
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  'AUTHENTICATING...',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.login, color: Colors.black, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'INITIATE NEURAL LOGIN',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricOption() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) => GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Biometric authentication not available in demo'),
              backgroundColor: const Color(0xFF808080),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1A1A2E).withOpacity(0.6),
                const Color(0xFF16213E).withOpacity(0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF808080).withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.scale(
                scale: _pulseAnimation.value,
                child: const Icon(
                  Icons.fingerprint,
                  color: Color(0xFF808080),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'USE BIOMETRIC AUTHENTICATION',
                style: TextStyle(
                  color: Color(0xFF808080),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignupLink() {
    return AnimatedBuilder(
      animation: _scanAnimation,
      builder: (context, child) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "No neural access? ",
            style: TextStyle(
              color: Color.lerp(const Color(0xFF808080), const Color(0xFF00FFFF), _scanAnimation.value)!,
              letterSpacing: 0.5,
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SignupPage()),
              );
            },
            child: ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  Color.lerp(const Color(0xFF00FFFF), const Color(0xFFFF00FF), _scanAnimation.value)!,
                  Color.lerp(const Color(0xFFFF00FF), const Color(0xFF00FFFF), _scanAnimation.value)!,
                ],
              ).createShader(bounds),
              child: const Text(
                'CREATE NEURAL PROFILE',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedCyberpunkTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) => ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                Color.lerp(const Color(0xFF00FFFF), const Color(0xFFFF00FF), _glowAnimation.value)!,
                Color.lerp(const Color(0xFFFF00FF), const Color(0xFF00FFFF), _glowAnimation.value)!,
              ],
            ).createShader(bounds),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) => Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1A1A2E).withOpacity(0.8),
                  const Color(0xFF16213E).withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Color.lerp(const Color(0xFF00FFFF), const Color(0xFFFF00FF), _glowAnimation.value)!.withOpacity(0.8),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Color.lerp(const Color(0xFF00FFFF), const Color(0xFFFF00FF), _glowAnimation.value)!.withOpacity(0.3),
                  blurRadius: 15,
                ),
              ],
            ),
            child: TextFormField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              validator: validator,
              style: const TextStyle(
                color: Color(0xFF00FFFF),
                fontSize: 16,
                letterSpacing: 0.5,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  color: Color(0xFF808080),
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
                prefixIcon: AnimatedBuilder(
                  animation: _scanAnimation,
                  builder: (context, child) => Icon(
                    icon,
                    color: Color.lerp(const Color(0xFF00FFFF), const Color(0xFFFF00FF), _scanAnimation.value)!,
                  ),
                ),
                suffixIcon: suffixIcon,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Custom painter for matrix rain effect
class MatrixPainter extends CustomPainter {
  final double animationValue;

  MatrixPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00FFFF).withOpacity(0.1)
      ..strokeWidth = 1;

    for (int i = 0; i < 20; i++) {
      final x = (size.width / 20) * i;
      final y = (animationValue * size.height * 2) % (size.height + 100) - 100;

      canvas.drawLine(
        Offset(x, y),
        Offset(x, y + 50),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Custom painter for circuit pattern
class CircuitPainter extends CustomPainter {
  final double animationValue;

  CircuitPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFF00FF).withOpacity(0.05)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    final path = Path();

    // Draw circuit-like patterns
    for (int i = 0; i < 10; i++) {
      final startX = (size.width / 10) * i;
      final startY = size.height * 0.3;

      path.moveTo(startX, startY);
      path.lineTo(startX + 20, startY);
      path.lineTo(startX + 20, startY + 30);
      path.lineTo(startX + 40, startY + 30);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}