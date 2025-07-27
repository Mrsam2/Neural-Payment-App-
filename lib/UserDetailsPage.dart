import 'package:flutter/material.dart';

class UserDetailsPage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const UserDetailsPage({super.key, required this.userData});

  @override
  State<UserDetailsPage> createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _pulseController;
  late Animation<double> _glowAnimation;
  late Animation<double> _pulseAnimation;

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

    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowController.repeat(reverse: true);
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Column(
        children: [
          // Cyberpunk Header Section
          _buildCyberpunkHeader(),

          // Main Content
          Expanded(
            child: _buildMainContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildCyberpunkHeader() {
    return Container(
      height: 280,
      width: double.infinity,
      child: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF00FFFF).withOpacity(0.4),
                  const Color(0xFFFF00FF).withOpacity(0.3),
                  const Color(0xFF0A0A0A).withOpacity(0.9),
                ],
              ),
            ),
          ),

          // Neural Grid Pattern Overlay
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) => Container(
              decoration: BoxDecoration(
                backgroundBlendMode: BlendMode.overlay,
                color: Color.lerp(
                    const Color(0xFF00FFFF),
                    const Color(0xFFFF00FF),
                    _glowAnimation.value
                )!.withOpacity(0.1),
              ),
            ),
          ),

          // App Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: AnimatedBuilder(
                      animation: _glowAnimation,
                      builder: (context, child) => Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF00FFFF).withOpacity(_glowAnimation.value * 0.8),
                              const Color(0xFF0080FF).withOpacity(_glowAnimation.value * 0.8),
                            ],
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF00FFFF).withOpacity(_glowAnimation.value),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00FFFF).withOpacity(_glowAnimation.value * 0.5),
                              blurRadius: 15,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: AnimatedBuilder(
                      animation: _glowAnimation,
                      builder: (context, child) => Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFFF00FF).withOpacity(_glowAnimation.value * 0.8),
                              const Color(0xFFFF0080).withOpacity(_glowAnimation.value * 0.8),
                            ],
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFFF00FF).withOpacity(_glowAnimation.value),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF00FF).withOpacity(_glowAnimation.value * 0.5),
                              blurRadius: 15,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.help_outline,
                          color: Colors.black,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1A1A2E),
            Color(0xFF0A0A0A),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: const Border(
          top: BorderSide(color: Color(0xFF00FFFF), width: 2),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00FFFF).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Neural Profile Details
            _buildNeuralProfileCard(),
            const SizedBox(height: 20),

            // Neural Financial Details
            _buildNeuralTile(
              title: 'NEURAL FINANCIAL DATA',
              subtitle: 'INCOME, EMPLOYMENT MATRIX AND MORE',
              icon: Icons.account_balance_wallet,
              colors: [const Color(0xFF00FF00), const Color(0xFF80FF00)],
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Neural financial data access initializing...'),
                    backgroundColor: Color(0xFF00FF00),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            // Additional Neural Details
            _buildNeuralTile(
              title: 'ADDITIONAL NEURAL DATA',
              subtitle: 'AGE, GENDER MATRIX AND MORE',
              icon: Icons.person_outline,
              colors: [const Color(0xFF0080FF), const Color(0xFF00FFFF)],
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Additional neural data access initializing...'),
                    backgroundColor: Color(0xFF0080FF),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // Neural Addresses Section
            _buildSectionTitle('NEURAL ADDRESSES'),
            const SizedBox(height: 16),

            _buildAddNewAddressCard(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildNeuralProfileCard() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1A1A2E).withOpacity(0.9),
              const Color(0xFF16213E).withOpacity(0.9),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Color.lerp(const Color(0xFF00FFFF), const Color(0xFFFF00FF), _glowAnimation.value)!,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Color.lerp(const Color(0xFF00FFFF), const Color(0xFFFF00FF), _glowAnimation.value)!.withOpacity(0.4),
              blurRadius: 25,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF00FFFF), Color(0xFFFF00FF)],
                  ).createShader(bounds),
                  child: const Text(
                    "NEURAL PROFILE DATA",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00FF00), Color(0xFF80FF00)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00FF00).withOpacity(0.5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // User Avatar
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00FFFF), Color(0xFFFF00FF)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00FFFF).withOpacity(0.5),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      widget.userData['fullName'] != null && widget.userData['fullName'].isNotEmpty
                          ? widget.userData['fullName'][0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFF00FFFF), Color(0xFFFF00FF)],
                        ).createShader(bounds),
                        child: Text(
                          (widget.userData['fullName'] ?? 'USER').toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "+91 ${widget.userData['mobileNumber'] ?? ''}",
                        style: const TextStyle(
                          color: Color(0xFF00FFFF),
                          fontSize: 14,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Email with verification badge
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.userData['email'] ?? 'No email provided',
                    style: const TextStyle(
                      color: Color(0xFF00FFFF),
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00FF00), Color(0xFF80FF00)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00FF00).withOpacity(0.5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const Text(
                    'VERIFIED',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // UPI ID
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF808080).withOpacity(0.2),
                    const Color(0xFF606060).withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF808080).withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Text(
                    'NEURAL ID: ',
                    style: TextStyle(
                      color: Color(0xFF808080),
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.userData['upiId'] ?? 'Not available',
                      style: const TextStyle(
                        color: Color(0xFF00FFFF),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNeuralTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> colors,
    VoidCallback? onTap,
  }) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1A1A2E).withOpacity(0.8),
              const Color(0xFF16213E).withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colors[0].withOpacity(_glowAnimation.value * 0.8),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colors[0].withOpacity(_glowAnimation.value * 0.3),
              blurRadius: 15,
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: colors),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: colors[0].withOpacity(0.5),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Icon(icon, color: Colors.black, size: 24),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: colors[0],
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF808080),
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: colors[0],
            size: 18,
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Color(0xFF00FFFF), Color(0xFFFF00FF)],
      ).createShader(bounds),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildAddNewAddressCard() {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Neural address addition protocol initializing...'),
            backgroundColor: Color(0xFF00FFFF),
          ),
        );
      },
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) => Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF00FFFF).withOpacity(0.1),
                  const Color(0xFFFF00FF).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF00FFFF).withOpacity(0.8), // Fixed: Using constant opacity
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00FFFF).withOpacity(0.3), // Fixed: Using constant opacity
                  blurRadius: 15,
                ),
              ],
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add,
                    color: Color(0xFF00FFFF),
                    size: 32,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "ADD NEW NEURAL ADDRESS",
                    style: TextStyle(
                      color: Color(0xFF00FFFF),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}