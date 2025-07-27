import 'package:flutter/material.dart';
import 'package:my_app/user_dashboard.dart';
import 'package:my_app/userpage.dart' hide PleaseWaitPage;
import 'package:my_app/Qrscan.dart';
import 'package:my_app/history.dart';
import 'package:my_app/home_page.dart';
import 'package:my_app/new_payment_history_page.dart';
import 'package:my_app/sync_notifications/sync_login_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 1; // Search tab is selected

  late AnimationController _glowController;
  late AnimationController _pulseController;
  late AnimationController _scanController;
  late Animation<double> _glowAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scanAnimation;

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

    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.linear),
    );

    _glowController.repeat(reverse: true);
    _pulseController.repeat(reverse: true);
    _scanController.repeat();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _glowController.dispose();
    _pulseController.dispose();
    _scanController.dispose();
    super.dispose();
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
          child: Column(
            children: [
              _buildCyberpunkHeader(),
              _buildSearchTitle(),
              const SizedBox(height: 24),
              _buildNeuralSearchBar(),
              const SizedBox(height: 40),
              _buildSearchForSection(),
              const SizedBox(height: 20),
              _buildCategoryGrid(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildCyberpunkBottomNav(),
    );
  }

  Widget _buildCyberpunkHeader() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1A1A2E).withOpacity(0.8),
              const Color(0xFF16213E).withOpacity(0.8),
            ],
          ),
          border: Border(
            bottom: BorderSide(
              color: Color.lerp(const Color(0xFF00FFFF), const Color(0xFFFF00FF), _glowAnimation.value)!,
              width: 2,
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 40),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF00FFFF), Color(0xFFFF00FF)],
              ).createShader(bounds),
              child: const Text(
                'NEURAL SEARCH HUB',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewPaymentHistoryPage(),
                  ),
                );

                if (result == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Neural transaction saved! Check your  history.'),
                      backgroundColor: const Color(0xFF00FF00),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF00FFFF).withOpacity(0.3),
                      const Color(0xFF0080FF).withOpacity(0.3),
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF00FFFF),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00FFFF).withOpacity(0.5),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.help_outline,
                  color: Color(0xFF00FFFF),
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF00FFFF), Color(0xFFFF00FF)],
          ).createShader(bounds),
          child: const Text(
            'SEARCH',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNeuralSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) => Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1A1A2E).withOpacity(0.8),
                const Color(0xFF16213E).withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: const Color(0xFF00FFFF).withOpacity(0.8),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00FFFF).withOpacity(0.3),
                blurRadius: 20,
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 20),
              AnimatedBuilder(
                animation: _scanAnimation,
                builder: (context, child) => Transform.rotate(
                  angle: _scanAnimation.value * 2 * 3.14159,
                  child: Icon(
                    Icons.search,
                    color: Color.lerp(const Color(0xFF00FFFF), const Color(0xFFFF00FF), _scanAnimation.value)!,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(
                    color: Color(0xFF00FFFF),
                    fontSize: 16,
                    letterSpacing: 1,
                  ),
                  decoration: InputDecoration(
                    hintText: "Search neural services...",
                    hintStyle: TextStyle(
                      color: const Color(0xFF808080).withOpacity(0.8),
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchForSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF808080), Color(0xFF00FFFF)],
          ).createShader(bounds),
          child: const Text(
            'NEURAL SERVICES AVAILABLE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            // First Row
            Row(
              children: [
                Expanded(
                  child: _buildCyberpunkCategoryButton('Neural Mobile Recharge', Icons.phone_android),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildCyberpunkCategoryButton('Loan Repayment', Icons.account_balance),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Second Row
            Row(
              children: [
                _buildCyberpunkCategoryButton('Cyber Rent', Icons.home),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildCyberpunkCategoryButton('Neural Credit Score', Icons.credit_score),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Third Row
            Row(
              children: [
                Expanded(
                  child: _buildCyberpunkCategoryButton('Refer & Earn ₹200', Icons.share),
                ),
                const SizedBox(width: 12),
                _buildCyberpunkCategoryButton('Neural Electricity', Icons.electrical_services),
              ],
            ),
            const SizedBox(height: 12),

            // Fourth Row
            Row(
              children: [
                _buildCyberpunkCategoryButton('Cyber FASTag', Icons.local_shipping),
                const SizedBox(width: 12),
                _buildCyberpunkCategoryButton('Funds', Icons.trending_up),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCyberpunkCategoryButton(String title, IconData icon) {
    return GestureDetector(
      onTap: () {
        _handleCategoryTap(title);
      },
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) => Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1A1A2E).withOpacity(0.6),
                const Color(0xFF16213E).withOpacity(0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFF00FFFF).withOpacity(0.8),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00FFFF).withOpacity(0.2),
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: Color.lerp(const Color(0xFF00FFFF), const Color(0xFFFF00FF), _glowAnimation.value)!,
                size: 16,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF00FFFF),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleCategoryTap(String category) {
    // Show neural feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${category.toUpperCase()} NEURAL PROTOCOL ACTIVATED'),
        backgroundColor: const Color(0xFF00FFFF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    // Handle navigation based on category
    switch (category) {
      case 'Neural Mobile Recharge':
        _navigateToNewPaymentWithType('mobile_recharge');
        break;
      case 'Loan Repayment':
      // Navigate to loan repayment page
        break;
      case 'Cyber Rent':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UserDashboard()),
        );
        break;
      case 'Neural Credit Score':
      // Navigate to credit score page
        break;
      case 'Refer & Earn ₹200':
      // Navigate to referral page
        break;
      case 'Neural Electricity':
      // Navigate to electricity bill page
        break;
      case 'Cyber FASTag':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SyncLoginPage()),
        );
        break;
      case 'Funds':
      // Navigate to mutual funds page
        break;
    }
  }

  void _navigateToNewPaymentWithType(String paymentType) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewPaymentHistoryPage(),
      ),
    );

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Neural transaction saved! Check your history.'),
          backgroundColor: const Color(0xFF00FF00),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Widget _buildCyberpunkBottomNav() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) => Container(
        height: 70,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF0A0A0A),
            ],
          ),
          border: Border(
            top: BorderSide(
              color: Color.lerp(const Color(0xFF00FFFF), const Color(0xFFFF00FF), _glowAnimation.value)!,
              width: 2,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Color.lerp(const Color(0xFF00FFFF), const Color(0xFFFF00FF), _glowAnimation.value)!.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCyberpunkNavItem(0, null, 'HOME', imagePath: 'assets/home.png'),
                _buildCyberpunkNavItem(1, Icons.search, ' SEARCH'),
                const SizedBox(width: 60), // Space for center button
                _buildCyberpunkNavItem(3, Icons.notifications_outlined, 'ALERTS'),
                _buildCyberpunkNavItem(4, Icons.access_time, 'HISTORY'),
              ],
            ),
            // Center QR code button
            Positioned(
              left: 0,
              right: 0,
              top: -14,
              child: Center(
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) => Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 56,
                      height: 95,
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
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Image.asset(
                          'assets/qr-code.png',
                          width: 40,
                          height: 40,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => QrScannerPage()),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCyberpunkNavItem(int index, IconData? icon, String label, {String? imagePath}) {
    bool isSelected = _selectedIndex == index;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });

        if (index == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        } else if (index == 4) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TransactionHistoryScreen()),
          );
        } else if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PleaseWaitPage(title: "Neural Alerts"),
            ),
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          imagePath != null
              ? Image.asset(
            imagePath,
            height: 24,
            width: 24,
            color: isSelected
                ? const Color(0xFF00FFFF)
                : const Color(0xFF808080),
          )
              : Icon(
            icon,
            color: isSelected
                ? const Color(0xFF00FFFF)
                : const Color(0xFF808080),
            size: 24,
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isSelected
                  ? const Color(0xFF00FFFF)
                  : const Color(0xFF808080),
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}