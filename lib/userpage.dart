import 'package:flutter/material.dart';
import 'QrCodeUPIID Page.dart';
import 'UserDetailsPage.dart';
import 'auth_service.dart';
import 'login_page.dart';

class UserPage extends StatefulWidget {
  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> with TickerProviderStateMixin {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  String? errorMessage;
  late AnimationController _glowController;
  late AnimationController _pulseController;
  late Animation<double> _glowAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _loadUserData();
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

  Future<void> _loadUserData() async {
    try {
      print('🔄 Loading neural profile data...');
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final data = await PersistentAuthService.getUserData();

      if (data != null) {
        print('✅ Neural profile loaded successfully: ${data['fullName']}');
        setState(() {
          userData = data;
          isLoading = false;
        });
      } else {
        print('❌ No neural profile data returned');
        setState(() {
          errorMessage = 'Neural profile not found. Please re-establish connection.';
          isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading neural profile: $e');
      setState(() {
        errorMessage = 'Failed to sync neural profile: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    try {
      await PersistentAuthService.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
              (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Neural disconnection failed: $e'),
          backgroundColor: const Color(0xFFFF0040),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            _buildCyberpunkAppBar(),
            Expanded(
              child: isLoading
                  ? _buildLoadingState()
                  : errorMessage != null
                  ? _buildErrorState()
                  : _buildProfileContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCyberpunkAppBar() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1A1A2E),
              const Color(0xFF16213E),
              const Color(0xFF0F3460),
            ],
          ),
          border: Border(
            bottom: BorderSide(
              color: Color.lerp(const Color(0xFF00FFFF), const Color(0xFFFF00FF), _glowAnimation.value)!,
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Color.lerp(const Color(0xFF00FFFF), const Color(0xFFFF00FF), _glowAnimation.value)!.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF00FFFF).withOpacity(0.2),
                      const Color(0xFF0080FF).withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF00FFFF), width: 1),
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Color(0xFF00FFFF),
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF00FFFF), Color(0xFFFF00FF)],
                ).createShader(bounds),
                child: const Text(
                  'NEURAL PROFILE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: _loadUserData,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF00FF00).withOpacity(0.2),
                          const Color(0xFF80FF00).withOpacity(0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF00FF00), width: 1),
                    ),
                    child: const Icon(
                      Icons.refresh,
                      color: Color(0xFF00FF00),
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFF00FF).withOpacity(0.2),
                          const Color(0xFFFF0080).withOpacity(0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFF00FF), width: 1),
                    ),
                    child: const Icon(
                      Icons.help_outline,
                      color: Color(0xFFFF00FF),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) => Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00FFFF), Color(0xFFFF00FF)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00FFFF).withOpacity(0.5),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const CircularProgressIndicator(
                  color: Colors.black,
                  strokeWidth: 3,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF00FFFF), Color(0xFFFF00FF)],
            ).createShader(bounds),
            child: const Text(
              'SYNCING NEURAL DATA...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF0040), Color(0xFFFF4080)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF0040).withOpacity(0.5),
                  blurRadius: 30,
                ),
              ],
            ),
            child: const Icon(
              Icons.error_outline,
              color: Colors.black,
              size: 50,
            ),
          ),
          const SizedBox(height: 24),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFFF0040), Color(0xFFFF4080)],
            ).createShader(bounds),
            child: Text(
              errorMessage!.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00FFFF), Color(0xFF0080FF)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00FFFF).withOpacity(0.5),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _loadUserData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'RETRY SYNC',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF00FF), Color(0xFFFF0080)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF00FF).withOpacity(0.5),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'RECONNECT',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildUserInfoCard(),
        const SizedBox(height: 24),
        _buildQuickActionsRow(),
        const SizedBox(height: 32),
        _buildSectionTitle('NEURAL PREFERENCES'),
        _buildCyberpunkListTile(context, Icons.language, 'LANGUAGE MATRIX'),
        _buildCyberpunkListTile(context, Icons.receipt_long, 'BILL NOTIFICATIONS'),
        _buildCyberpunkListTile(context, Icons.settings, 'SYSTEM PERMISSIONS'),
        _buildCyberpunkListTile(context, Icons.brightness_6, 'VISUAL THEME'),
        _buildCyberpunkListTile(context, Icons.notifications, 'NEURAL REMINDERS'),
        const SizedBox(height: 24),
        _buildSectionTitle('SECURITY PROTOCOLS'),
        _buildCyberpunkSwitchTile(Icons.fingerprint, 'BIOMETRIC LOCK', false),
        _buildCyberpunkListTile(context, Icons.vpn_key, 'PASSCODE SETUP'),
        _buildCyberpunkListTile(context, Icons.block, 'BLOCKED ENTITIES'),
        const SizedBox(height: 24),
        _buildCyberpunkListTile(context, Icons.info_outline, 'SYSTEM INFO'),
        _buildLogoutTile(),
      ],
    );
  }

  Widget _buildUserInfoCard() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1A1A2E).withOpacity(0.8),
              const Color(0xFF16213E).withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Color.lerp(const Color(0xFF00FFFF), const Color(0xFFFF00FF), _glowAnimation.value)!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Color.lerp(const Color(0xFF00FFFF), const Color(0xFFFF00FF), _glowAnimation.value)!.withOpacity(0.3),
              blurRadius: 25,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00FFFF), Color(0xFFFF00FF)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00FFFF).withOpacity(0.5),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  userData!['fullName'] != null && userData!['fullName'].isNotEmpty
                      ? userData!['fullName'][0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF00FFFF), Color(0xFFFF00FF)],
                    ).createShader(bounds),
                    child: Text(
                      (userData!['fullName'] ?? 'USER').toUpperCase(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '+91 ${userData!['mobileNumber'] ?? ''}',
                    style: const TextStyle(
                      color: Color(0xFF00FFFF),
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userData!['email'] ?? '',
                    style: const TextStyle(
                      color: Color(0xFF808080),
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserDetailsPage(userData: userData!),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00FF00), Color(0xFF80FF00)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00FF00).withOpacity(0.5),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: const Text(
                  'MANAGE',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsRow() {
    return Row(
      children: [
        _buildCyberpunkCardButton(
          context,
          icon: Icons.qr_code,
          label: "QR CODES &\nNEURAL IDs",
          colors: [const Color(0xFF00FFFF), const Color(0xFF0080FF)],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const QRCodeScreen()),
            );
          },
        ),
        const SizedBox(width: 16),
        _buildCyberpunkCardButton(
          context,
          icon: Icons.currency_rupee,
          label: "MANAGE\nTRANSFERS",
          colors: [const Color(0xFFFF00FF), const Color(0xFFFF0080)],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PleaseWaitPage(title: "Neural Transfer Management"),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCyberpunkCardButton(
      BuildContext context, {
        required IconData icon,
        required String label,
        required List<Color> colors,
        required VoidCallback onTap,
      }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) => Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colors[0].withOpacity(0.2),
                  colors[1].withOpacity(0.2),
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
            child: Column(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: colors),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: colors[0].withOpacity(0.5),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.black, size: 28),
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: colors[0],
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: ShaderMask(
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
      ),
    );
  }

  Widget _buildCyberpunkListTile(
      BuildContext context,
      IconData icon,
      String title, {
        Color? iconColor,
        Color? textColor,
        VoidCallback? onTap,
      }) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1A1A2E).withOpacity(0.6),
              const Color(0xFF16213E).withOpacity(0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF00FFFF).withOpacity(_glowAnimation.value * 0.5),
            width: 0.5,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Icon(
            icon,
            color: iconColor ?? const Color(0xFF00FFFF),
            size: 24,
          ),
          title: Text(
            title,
            style: TextStyle(
              color: textColor ?? const Color(0xFF00FFFF),
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: 1,
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: const Color(0xFF808080),
          ),
          onTap: onTap ??
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PleaseWaitPage(title: title),
                  ),
                );
              },
        ),
      ),
    );
  }

  Widget _buildCyberpunkSwitchTile(IconData icon, String title, bool value) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1A1A2E).withOpacity(0.6),
              const Color(0xFF16213E).withOpacity(0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF00FFFF).withOpacity(_glowAnimation.value * 0.5),
            width: 0.5,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Icon(icon, color: const Color(0xFF00FFFF), size: 24),
          title: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF00FFFF),
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: 1,
            ),
          ),
          trailing: Switch(
            value: value,
            onChanged: (_) {},
            activeColor: const Color(0xFF00FF00),
            inactiveThumbColor: const Color(0xFF808080),
            inactiveTrackColor: const Color(0xFF404040),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutTile() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFFF0040).withOpacity(0.2),
              const Color(0xFFFF4080).withOpacity(0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFFF0040).withOpacity(_glowAnimation.value * 0.8),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF0040).withOpacity(_glowAnimation.value * 0.3),
              blurRadius: 15,
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: const Icon(
            Icons.logout,
            color: Color(0xFFFF0040),
            size: 24,
          ),
          title: const Text(
            'NEURAL DISCONNECT',
            style: TextStyle(
              color: Color(0xFFFF0040),
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Color(0xFFFF0040),
          ),
          onTap: _logout,
        ),
      ),
    );
  }
}

// Cyberpunk Loading Screen
class PleaseWaitPage extends StatefulWidget {
  final String title;
  const PleaseWaitPage({super.key, required this.title});

  @override
  State<PleaseWaitPage> createState() => _PleaseWaitPageState();
}

class _PleaseWaitPageState extends State<PleaseWaitPage> with TickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF00FFFF), Color(0xFFFF00FF)],
          ).createShader(bounds),
          child: Text(
            widget.title.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        leading: const BackButton(color: Color(0xFF00FFFF)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) => Container(
                width: 100,
                height: 100,
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
                      color: Color.lerp(const Color(0xFF00FFFF), const Color(0xFFFF00FF), _glowAnimation.value)!.withOpacity(0.6),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const CircularProgressIndicator(
                  color: Colors.black,
                  strokeWidth: 4,
                ),
              ),
            ),
            const SizedBox(height: 30),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF00FFFF), Color(0xFFFF00FF)],
              ).createShader(bounds),
              child: const Text(
                "INITIALIZING NEURAL LINK...",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}