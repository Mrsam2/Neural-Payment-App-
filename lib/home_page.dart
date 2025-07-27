import 'dart:async';
import 'package:flutter/material.dart';
import 'package:my_app/send%20money.dart';
import 'package:my_app/tobank.dart';
import 'package:my_app/userpage.dart';
import 'Qrscan.dart';
import 'checkBalence.dart';
import 'history.dart';
import 'search_page.dart';
import 'add_upi_popup.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late AnimationController _glowController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _showAddUpiPopup() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF0A0A0A),
                  const Color(0xFF1A1A2E),
                  const Color(0xFF16213E),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF00FFFF),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00FFFF).withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.8),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF00FFFF), Color(0xFFFF00FF)],
                  ).createShader(bounds),
                  child: const Text(
                    'UPI NEURAL LINK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Access quantum payment protocols',
                  style: TextStyle(
                    color: Color(0xFF00FFFF),
                    fontSize: 14,
                    letterSpacing: 1,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFF00FF)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF00FF).withOpacity(0.3),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide.none,
                            backgroundColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'ABORT',
                            style: TextStyle(
                              color: Color(0xFFFF00FF),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
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
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'EXECUTE',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Cyberpunk Header Section
                _buildCyberpunkHeader(),

                const SizedBox(height: 32),

                // Neural Transfer Grid
                _buildNeuralTransfersSection(),

                const SizedBox(height: 40),

                // Quantum Actions
                _buildQuantumActionsSection(),

                const SizedBox(height: 40),

                // Neon Promotional Banner
                _buildNeonPromotionalBanner(),

                const SizedBox(height: 40),

                // Data Stream Activity
                _buildDataStreamActivity(),

                const SizedBox(height: 120), // Space for bottom nav
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildCyberpunkBottomNavigationBar(),
    );
  }

  Widget _buildCyberpunkHeader() {
    return Container(
      height: 320,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0A0A0A),
            const Color(0xFF1A1A2E),
            const Color(0xFF16213E),
            const Color(0xFF0F3460),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Animated grid background
          ...List.generate(20, (index) => Positioned(
            left: (index % 5) * 80.0,
            top: (index ~/ 5) * 80.0,
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) => Container(
                width: 1,
                height: 80,
                color: const Color(0xFF00FFFF).withOpacity(_glowAnimation.value * 0.1),
              ),
            ),
          )),

          // Header Controls
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UserPage()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF00FFFF).withOpacity(0.2),
                          const Color(0xFF0080FF).withOpacity(0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF00FFFF), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00FFFF).withOpacity(0.3),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      color: Color(0xFF00FFFF),
                      size: 24,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _showAddUpiPopup,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFF00FF).withOpacity(0.2),
                          const Color(0xFFFF0080).withOpacity(0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFF00FF), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF00FF).withOpacity(0.3),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.help_outline,
                      color: Color(0xFFFF00FF),
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Cyberpunk Welcome Text
          Positioned(
            top: 90,
            left: 0,
            right: 0,
            child: Column(
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF00FFFF), Color(0xFFFF00FF), Color(0xFF00FF00)],
                  ).createShader(bounds),
                  child: const Text(
                    'NEURAL INTERFACE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'QUANTUM PAYMENT PROTOCOL ACTIVE',
                  style: TextStyle(
                    color: Color(0xFF00FFFF),
                    fontSize: 14,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),

          // Cyberpunk Balance Card
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) => Container(
                padding: const EdgeInsets.all(24),
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
                    color: Color.lerp(
                      const Color(0xFF00FFFF),
                      const Color(0xFF00FF00),
                      _glowAnimation.value,
                    )!,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color.lerp(
                        const Color(0xFF00FFFF),
                        const Color(0xFF00FF00),
                        _glowAnimation.value,
                      )!.withOpacity(0.4),
                      blurRadius: 25,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CREDIT BALANCE',
                          style: TextStyle(
                            color: Color(0xFF00FFFF),
                            fontSize: 12,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFF00FF00), Color(0xFF00FFFF)],
                          ).createShader(bounds),
                          child: const Text(
                            '₹12,450.00',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00FF00), Color(0xFF00FFFF)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00FF00).withOpacity(0.5),
                            blurRadius: 15,
                          ),
                        ],
                      ),
                      child: const Text(
                        'ONLINE',
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNeuralTransfersSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF00FFFF), Color(0xFFFF00FF)],
            ).createShader(bounds),
            child: const Text(
              "NEURAL TRANSFERS",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCyberpunkTransferCard(
                icon: Icons.smartphone,
                title: "MOBILE",
                subtitle: "LINK",
                colors: [const Color(0xFF00FFFF), const Color(0xFF0080FF)],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SendMoneyPage1()),
                  );
                },
              ),
              _buildCyberpunkTransferCard(
                icon: Icons.account_balance,
                title: "BANK",
                subtitle: "VAULT",
                colors: [const Color(0xFF00FF00), const Color(0xFF80FF00)],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SendMoneyPage()),
                  );
                },
              ),
              _buildCyberpunkTransferCard(
                icon: Icons.account_balance_wallet,
                title: "BALANCE",
                subtitle: "SCAN",
                colors: [const Color(0xFFFF00FF), const Color(0xFFFF0080)],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CheckBalancePage()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCyberpunkTransferCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) => Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: colors,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colors[0].withOpacity(_glowAnimation.value),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors[0].withOpacity(_glowAnimation.value * 0.6),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.black,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF00FFFF),
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              subtitle,
              style: const TextStyle(
                color: Color(0xFF808080),
                fontSize: 11,
                letterSpacing: 1,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantumActionsSection() {
    final quantumActions = [
      {
        'icon': Icons.flash_on,
        'title': 'ENERGY RECHARGE',
        'subtitle': 'Mobile & DTH Quantum Link',
        'colors': [const Color(0xFFFFFF00), const Color(0xFFFF8000)],
        'onTap': () => Navigator.push(context, MaterialPageRoute(
            builder: (context) => const PleaseWaitPage(title: "Energy Recharge")))
      },
      {
        'icon': Icons.receipt_long,
        'title': 'BILL MATRIX',
        'subtitle': 'Electricity & Data Stream',
        'colors': [const Color(0xFF8000FF), const Color(0xFFFF00FF)],
        'onTap': () => Navigator.push(context, MaterialPageRoute(
            builder: (context) => const PleaseWaitPage(title: "Bill Matrix")))
      },
      {
        'icon': Icons.card_giftcard,
        'title': 'REWARD PROTOCOL',
        'subtitle': 'Cashback & Neural Bonuses',
        'colors': [const Color(0xFF00FF80), const Color(0xFF00FFFF)],
        'onTap': () => Navigator.push(context, MaterialPageRoute(
            builder: (context) => const PleaseWaitPage(title: "Reward Protocol")))
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFFF00FF), Color(0xFF00FFFF)],
            ).createShader(bounds),
            child: const Text(
              "QUANTUM ACTIONS",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ...quantumActions.map((action) => Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: GestureDetector(
              onTap: action['onTap'] as VoidCallback,
              child: AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) => Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF1A1A2E).withOpacity(0.6),
                        const Color(0xFF16213E).withOpacity(0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: (action['colors'] as List<Color>)[0].withOpacity(_glowAnimation.value * 0.8),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (action['colors'] as List<Color>)[0].withOpacity(_glowAnimation.value * 0.3),
                        blurRadius: 15,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: action['colors'] as List<Color>,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: (action['colors'] as List<Color>)[0].withOpacity(0.5),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Icon(
                          action['icon'] as IconData,
                          color: Colors.black,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              action['title'] as String,
                              style: const TextStyle(
                                color: Color(0xFF00FFFF),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              action['subtitle'] as String,
                              style: const TextStyle(
                                color: Color(0xFF808080),
                                fontSize: 13,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: (action['colors'] as List<Color>)[0],
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildNeonPromotionalBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) => Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(const Color(0xFFFF00FF), const Color(0xFFFFFF00), _glowAnimation.value)!,
                Color.lerp(const Color(0xFF00FFFF), const Color(0xFFFF00FF), _glowAnimation.value)!,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF00FF).withOpacity(_glowAnimation.value * 0.6),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'NEURAL BOOST!',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Get 5% quantum cashback on all transactions',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'ACTIVATE',
                          style: TextStyle(
                            color: Color(0xFF00FFFF),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: const Icon(
                  Icons.card_giftcard,
                  color: Colors.black,
                  size: 40,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataStreamActivity() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF00FF00), Color(0xFF00FFFF)],
                ).createShader(bounds),
                child: const Text(
                  "DATA STREAM",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TransactionHistoryScreen()),
                  );
                },
                child: const Text(
                  'VIEW ALL',
                  style: TextStyle(
                    color: Color(0xFF00FFFF),
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...List.generate(3, (index) => Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1A1A2E).withOpacity(0.6),
                  const Color(0xFF16213E).withOpacity(0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF00FF00).withOpacity(0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00FF00).withOpacity(0.2),
                  blurRadius: 15,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00FF00), Color(0xFF00FFFF)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00FF00).withOpacity(0.5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.smartphone,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MOBILE ENERGY BOOST',
                        style: TextStyle(
                          color: Color(0xFF00FFFF),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '+91 98765 43210',
                        style: TextStyle(
                          color: Color(0xFF808080),
                          fontSize: 14,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF00FF00), Color(0xFF00FFFF)],
                      ).createShader(bounds),
                      child: const Text(
                        '₹299',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00FF00), Color(0xFF00FFFF)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'SUCCESS',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildCyberpunkBottomNavigationBar() {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF1A1A2E).withOpacity(0.9),
            const Color(0xFF0A0A0A),
          ],
        ),
        border: Border(
          top: BorderSide(
            color: const Color(0xFF00FFFF).withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCyberpunkNavItem(0, Icons.home_outlined, 'HOME'),
              _buildCyberpunkNavItem(1, Icons.search, 'SEARCH'),
              const SizedBox(width: 80), // Space for center button
              _buildCyberpunkNavItem(3, Icons.notifications_outlined, 'ALERTS'),
              _buildCyberpunkNavItem(4, Icons.access_time, 'HISTORY'),
            ],
          ),
          // Center QR Scanner Button
          Positioned(
            left: 0,
            right: 0,
            top: -1,
            child: Center(
              child: AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) => Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.lerp(const Color(0xFF00FFFF), const Color(0xFFFF00FF), _glowAnimation.value)!,
                        Color.lerp(const Color(0xFFFF00FF), const Color(0xFF00FFFF), _glowAnimation.value)!,
                      ],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF00FFFF), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Color.lerp(const Color(0xFF00FFFF), const Color(0xFFFF00FF), _glowAnimation.value)!.withOpacity(0.6),
                        blurRadius: 25,
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
        ],
      ),
    );
  }

  Widget _buildCyberpunkNavItem(int index, IconData icon, String label) {
    bool isSelected = _selectedIndex == index;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });

        if (index == 1) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => SearchPage()));
        } else if (index == 4) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => TransactionHistoryScreen()));
        } else if (index == 3) {
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => const PleaseWaitPage(title: "Neural Alerts")));
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF00FFFF) : const Color(0xFF808080),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? const Color(0xFF00FFFF) : const Color(0xFF808080),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Updated placeholder pages with cyberpunk theme
class PlaceholderPage extends StatelessWidget {
  final String title;

  const PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title.toUpperCase(),
          style: const TextStyle(letterSpacing: 2),
        ),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: const Color(0xFF00FFFF),
      ),
      backgroundColor: const Color(0xFF0A0A0A),
      body: Center(
        child: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF00FFFF), Color(0xFFFF00FF)],
          ).createShader(bounds),
          child: Text(
            "NEURAL INTERFACE: ${title.toUpperCase()}",
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class PleaseWaitPage extends StatelessWidget {
  final String title;

  const PleaseWaitPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title.toUpperCase(),
          style: const TextStyle(letterSpacing: 2),
        ),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: const Color(0xFF00FFFF),
      ),
      backgroundColor: const Color(0xFF0A0A0A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                strokeWidth: 3,
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

// Keep the existing ImageSlider class with cyberpunk styling
class ImageSlider extends StatefulWidget {
  @override
  _ImageSliderState createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<String> _imagePaths = [
    'assets/b1.png',
    'assets/b1.png',
  ];

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_currentPage < _imagePaths.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      _controller.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 160,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF00FFFF), width: 1),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00FFFF).withOpacity(0.3),
                blurRadius: 15,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: PageView.builder(
              controller: _controller,
              itemCount: _imagePaths.length,
              itemBuilder: (context, index) {
                return Image.asset(
                  _imagePaths[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                );
              },
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_imagePaths.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 6,
              width: _currentPage == index ? 20 : 6,
              decoration: BoxDecoration(
                gradient: _currentPage == index
                    ? const LinearGradient(colors: [Color(0xFF00FFFF), Color(0xFFFF00FF)])
                    : null,
                color: _currentPage == index ? null : const Color(0xFF808080),
                borderRadius: BorderRadius.circular(3),
                boxShadow: _currentPage == index ? [
                  BoxShadow(
                    color: const Color(0xFF00FFFF).withOpacity(0.5),
                    blurRadius: 10,
                  ),
                ] : null,
              ),
            );
          }),
        ),
      ],
    );
  }
}