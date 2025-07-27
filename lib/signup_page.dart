import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'auth_service.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'dart:math' as math;

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _upiIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  final _tokenPinController = TextEditingController();

  bool _isLoading = false;
  bool _isPinVisible = false;
  bool _isConfirmPinVisible = false;
  int _currentStep = 0;

  late AnimationController _glowController;
  late AnimationController _pulseController;
  late AnimationController _scanController;
  late AnimationController _progressController;
  late Animation<double> _glowAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scanAnimation;
  late Animation<double> _progressAnimation;

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
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1000),
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
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _glowController.repeat(reverse: true);
    _pulseController.repeat(reverse: true);
    _scanController.repeat();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _mobileController.dispose();
    _upiIdController.dispose();
    _emailController.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
    _tokenPinController.dispose();
    _glowController.dispose();
    _pulseController.dispose();
    _scanController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // Animate progress
    _progressController.forward();
    HapticFeedback.mediumImpact();

    try {
      final emailExists = await PersistentAuthService.emailExists(_emailController.text.trim());
      if (emailExists) throw 'Neural email already registered in quantum database';

      final mobileExists = await PersistentAuthService.mobileExists(_mobileController.text.trim());
      if (mobileExists) throw 'Neural mobile ID already exists in network';

      final upiExists = await PersistentAuthService.upiIdExists(_upiIdController.text.trim());
      if (upiExists) throw 'Quantum UPI address already registered';

      await PersistentAuthService.signUp(
        fullName: _fullNameController.text.trim(),
        mobileNumber: _mobileController.text.trim(),
        upiId: _upiIdController.text.trim(),
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
                Text('Neural profile created successfully!'),
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
                Expanded(child: Text('Neural registration error: $e')),
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
        setState(() => _isLoading = false);
        _progressController.reset();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Container(
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
                  const SizedBox(height: 40),
                  _buildEnhancedCyberpunkHeader(),
                  const SizedBox(height: 32),
                  _buildProgressIndicator(),
                  const SizedBox(height: 32),
                  _buildFormFields(),
                  const SizedBox(height: 40),
                  _buildEnhancedSignupButton(),
                  const SizedBox(height: 24),
                  _buildLoginLink(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedCyberpunkHeader() {
    return Column(
      children: [
        // Enhanced holographic signup icon
        Stack(
          alignment: Alignment.center,
          children: [
            // Rotating outer ring
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
                      color: const Color(0xFF00FFFF).withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: CustomPaint(
                    painter: HexagonPainter(_scanAnimation.value),
                  ),
                ),
              ),
            ),
            // Main icon
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) => Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 100,
                  height: 100,
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
                            blurRadius: 35,
                            spreadRadius: 12,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person_add,
                        color: Colors.black,
                        size: 50,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Enhanced title
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
              'NEURAL PROFILE CREATION',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) => Text(
            'REGISTER FOR QUANTUM NETWORK ACCESS',
            style: TextStyle(
              color: Color.lerp(const Color(0xFF808080), const Color(0xFF00FFFF), _glowAnimation.value)!,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A1A2E).withOpacity(0.8),
            const Color(0xFF16213E).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF00FFFF).withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'NEURAL PROFILE COMPLETION',
                style: TextStyle(
                  color: Color(0xFF00FFFF),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              Text(
                '${(_getCompletionPercentage() * 100).toInt()}%',
                style: const TextStyle(
                  color: Color(0xFF00FF00),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) => LinearProgressIndicator(
              value: _getCompletionPercentage(),
              backgroundColor: const Color(0xFF1A1A2E),
              valueColor: AlwaysStoppedAnimation<Color>(
                Color.lerp(const Color(0xFF00FFFF), const Color(0xFF00FF00), _getCompletionPercentage())!,
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _getCompletionPercentage() {
    int filledFields = 0;
    if (_fullNameController.text.isNotEmpty) filledFields++;
    if (_mobileController.text.isNotEmpty) filledFields++;
    if (_upiIdController.text.isNotEmpty) filledFields++;
    if (_emailController.text.isNotEmpty) filledFields++;
    if (_pinController.text.isNotEmpty) filledFields++;
    if (_confirmPinController.text.isNotEmpty) filledFields++;
    if (_tokenPinController.text.isNotEmpty) filledFields++;
    return filledFields / 7;
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        _buildFullNameField(),
        const SizedBox(height: 20),
        _buildMobileField(),
        const SizedBox(height: 20),
        _buildUpiIdField(),
        const SizedBox(height: 20),
        _buildEmailField(),
        const SizedBox(height: 20),
        _buildPinField(),
        const SizedBox(height: 20),
        _buildConfirmPinField(),
        const SizedBox(height: 20),
        _buildTokenPinField(),
      ],
    );
  }

  Widget _buildFullNameField() {
    return _buildEnhancedCyberpunkTextField(
      controller: _fullNameController,
      label: 'NEURAL IDENTITY NAME',
      hint: 'Enter your full neural identity',
      icon: Icons.person,
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'Neural identity name required';
        if (value.trim().length < 2) return 'Name must be at least 2 characters';
        return null;
      },
    );
  }

  Widget _buildMobileField() {
    return _buildEnhancedCyberpunkTextField(
      controller: _mobileController,
      label: 'NEURAL MOBILE ID',
      hint: 'Enter your 10-digit neural mobile ID',
      icon: Icons.phone,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10)
      ],
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'Neural mobile ID required';
        if (value.trim().length != 10) return 'Neural mobile ID must be 10 digits';
        return null;
      },
    );
  }

  Widget _buildUpiIdField() {
    return _buildEnhancedCyberpunkTextField(
      controller: _upiIdController,
      label: 'QUANTUM UPI ADDRESS',
      hint: 'Enter your quantum UPI address',
      icon: Icons.account_balance_wallet,
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'Quantum UPI address required';
        if (!value.contains('@')) return 'Invalid quantum UPI format (e.g., user@bank)';
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return _buildEnhancedCyberpunkTextField(
      controller: _emailController,
      label: 'NEURAL EMAIL ADDRESS',
      hint: 'Enter your neural email address',
      icon: Icons.email,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'Neural email address required';
        if (!RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Invalid neural email format';
        return null;
      },
    );
  }

  Widget _buildPinField() {
    return _buildEnhancedCyberpunkTextField(
      controller: _pinController,
      label: 'CREATE QUANTUM ACCESS PIN',
      hint: 'Create your 4-digit quantum PIN',
      icon: Icons.lock,
      obscureText: !_isPinVisible,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4)
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
          setState(() => _isPinVisible = !_isPinVisible);
          HapticFeedback.lightImpact();
        },
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'Quantum access PIN required';
        if (value.trim().length != 4) return 'PIN must be exactly 4 digits';
        return null;
      },
    );
  }

  Widget _buildConfirmPinField() {
    return _buildEnhancedCyberpunkTextField(
      controller: _confirmPinController,
      label: 'CONFIRM QUANTUM PIN',
      hint: 'Re-enter your quantum PIN',
      icon: Icons.lock_outline,
      obscureText: !_isConfirmPinVisible,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4)
      ],
      suffixIcon: IconButton(
        icon: AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) => Icon(
            _isConfirmPinVisible ? Icons.visibility : Icons.visibility_off,
            color: Color.lerp(const Color(0xFF00FFFF), const Color(0xFFFF00FF), _glowAnimation.value)!,
          ),
        ),
        onPressed: () {
          setState(() => _isConfirmPinVisible = !_isConfirmPinVisible);
          HapticFeedback.lightImpact();
        },
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'Please confirm your quantum PIN';
        if (value.trim() != _pinController.text.trim()) return 'Quantum PINs do not match';
        return null;
      },
    );
  }

  Widget _buildTokenPinField() {
    return _buildEnhancedCyberpunkTextField(
      controller: _tokenPinController,
      label: 'NEURAL AUTHORIZATION TOKEN',
      hint: 'Enter neural authorization token',
      icon: Icons.vpn_key,
      obscureText: true,
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'Neural authorization token required';
        if (value.trim() != 'Saurabh') return 'Invalid neural authorization token';
        return null;
      },
    );
  }

  Widget _buildEnhancedSignupButton() {
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
            onPressed: _isLoading ? null : _signUp,
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
                  'CREATING NEURAL PROFILE...',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person_add, color: Colors.black, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'CREATE NEURAL PROFILE',
                  style: TextStyle(
                    fontSize: 16,
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

  Widget _buildLoginLink() {
    return AnimatedBuilder(
      animation: _scanAnimation,
      builder: (context, child) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Already have neural access? ",
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
                MaterialPageRoute(builder: (context) => const LoginPage()),
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
                'NEURAL LOGIN',
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
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool obscureText = false,
    Widget? suffixIcon,
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
              validator: validator,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              obscureText: obscureText,
              onChanged: (value) => setState(() {}), // Update progress
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

// Custom painter for hexagon pattern
class HexagonPainter extends CustomPainter {
  final double animationValue;

  HexagonPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFF00FF).withOpacity(0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3;

    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 + animationValue * 360) * math.pi / 180;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}