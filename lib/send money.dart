import 'package:flutter/material.dart';

class SendMoneyPage1 extends StatefulWidget {
  const SendMoneyPage1({super.key});

  @override
  State<SendMoneyPage1> createState() => _SendMoneyPage1State();
}

class _SendMoneyPage1State extends State<SendMoneyPage1> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _glowController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _pulseAnimation;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _animationController.forward();
    _glowController.repeat(reverse: true);
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _glowController.dispose();
    _pulseController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                _buildCyberpunkAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeaderSection(),
                        const SizedBox(height: 24),
                        _buildNeuralAppsSection(),
                        const SizedBox(height: 24),
                        _buildQuantumSearchSection(),
                        const SizedBox(height: 24),
                        _buildNeuralActionsSection(),
                        const SizedBox(height: 32),
                        _buildRecentTransfersSection(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildQuantumFAB(),
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
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
          border: Border.all(
            color: Color.lerp(const Color(0xFF00FFFF), const Color(0xFFFF00FF), _glowAnimation.value)!,
            width: 1,
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
                  "QUANTUM TRANSFER",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
            _buildAppBarAction(Icons.refresh, const Color(0xFF00FF00)),
            const SizedBox(width: 12),
            _buildAppBarAction(Icons.help_outline, const Color(0xFFFF00FF)),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBarAction(IconData icon, Color color) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.2),
              color.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 1),
        ),
        child: Icon(
          icon,
          color: color,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF00FFFF), Color(0xFFFF00FF)],
          ).createShader(bounds),
          child: const Text(
            "INITIATE NEURAL TRANSFER",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF00FF00).withOpacity(0.2),
                const Color(0xFF80FF00).withOpacity(0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF00FF00).withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00FF00).withOpacity(0.3),
                blurRadius: 10,
              ),
            ],
          ),
          child: const Text(
            "TO ANY NEURAL NETWORK",
            style: TextStyle(
              color: Color(0xFF00FF00),
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNeuralAppsSection() {
    final neuralApps = [
      {'name': 'PhonePe', 'color': const Color(0xFF00FFFF)},
      {'name': 'BHIM', 'color': const Color(0xFF0080FF)},
      {'name': 'GPay', 'color': const Color(0xFF00FF00)},
      {'name': 'Paytm', 'color': const Color(0xFFFF00FF)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF00FFFF), Color(0xFFFF00FF)],
          ).createShader(bounds),
          child: const Text(
            "NEURAL COMPATIBILITY",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: neuralApps.map((app) => Expanded(
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) => Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF1A1A2E).withOpacity(0.8),
                      const Color(0xFF16213E).withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (app['color'] as Color).withOpacity(_glowAnimation.value * 0.8),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (app['color'] as Color).withOpacity(_glowAnimation.value * 0.3),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            app['color'] as Color,
                            (app['color'] as Color).withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: (app['color'] as Color).withOpacity(0.5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          (app['name'] as String)[0],
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      (app['name'] as String).toUpperCase(),
                      style: TextStyle(
                        color: app['color'] as Color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildQuantumSearchSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF00FFFF), Color(0xFFFF00FF)],
          ).createShader(bounds),
          child: const Text(
            "INITIATE NEW TRANSFER",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 16),
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
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF00FFFF).withOpacity(_glowAnimation.value * 0.8),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00FFFF).withOpacity(_glowAnimation.value * 0.3),
                  blurRadius: 20,
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(
                color: Color(0xFF00FFFF),
                fontSize: 16,
                letterSpacing: 1,
              ),
              decoration: InputDecoration(
                hintText: 'ENTER NEURAL ID OR MOBILE',
                hintStyle: const TextStyle(
                  color: Color(0xFF808080),
                  letterSpacing: 1,
                ),
                prefixIcon: Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00FFFF), Color(0xFFFF00FF)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00FFFF).withOpacity(0.5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.search,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNeuralActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF00FFFF), Color(0xFFFF00FF)],
          ).createShader(bounds),
          child: const Text(
            "NEURAL ACTIONS",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildReceiveQuantumCard(),
        const SizedBox(height: 12),
        _buildSplitExpensesCard(),
      ],
    );
  }

  Widget _buildReceiveQuantumCard() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF00FF00).withOpacity(0.2),
              const Color(0xFF80FF00).withOpacity(0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF00FF00).withOpacity(_glowAnimation.value * 0.8),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00FF00).withOpacity(_glowAnimation.value * 0.3),
              blurRadius: 20,
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
              child: const Icon(
                Icons.qr_code,
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
                    "RECEIVE QUANTUM CREDITS",
                    style: TextStyle(
                      color: Color(0xFF00FF00),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "FROM ALL NEURAL NETWORKS",
                    style: TextStyle(
                      color: Color(0xFF808080),
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00FF00), Color(0xFF80FF00)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00FF00).withOpacity(0.5),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Text(
                "ACTIVATE",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSplitExpensesCard() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0080FF).withOpacity(0.2),
              const Color(0xFF00FFFF).withOpacity(0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF0080FF).withOpacity(_glowAnimation.value * 0.8),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0080FF).withOpacity(_glowAnimation.value * 0.3),
              blurRadius: 20,
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
                  colors: [Color(0xFF0080FF), Color(0xFF00FFFF)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0080FF).withOpacity(0.5),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: const Icon(
                Icons.receipt_long,
                color: Colors.black,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        "SPLIT NEURAL EXPENSES",
                        style: TextStyle(
                          color: Color(0xFF0080FF),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                          "NEW",
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
                  const SizedBox(height: 4),
                  const Text(
                    "TRACK & SETTLE WITH NEURAL CONTACTS",
                    style: TextStyle(
                      color: Color(0xFF808080),
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF0080FF),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransfersSection() {
    final recentTransfers = [
      {
        'name': 'Sagr Ingde Clg',
        'initials': 'SC',
        'amount': '₹20',
        'date': '27/02',
        'isAsset': false,
      },
      {
        'name': 'Dada💝💝💝',
        'initials': 'assets/dada.png',
        'amount': '₹500',
        'date': '06/02',
        'isAsset': true,
      },
      {
        'name': 'Monish💗',
        'initials': 'M',
        'amount': '₹20',
        'date': '24/01',
        'isAsset': false,
      },
      {
        'name': 'VIKRANT Dho',
        'initials': 'VD',
        'amount': '₹20',
        'date': '20/01',
        'isAsset': false,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF00FFFF), Color(0xFFFF00FF)],
          ).createShader(bounds),
          child: const Text(
            "RECENT NEURAL TRANSFERS",
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...recentTransfers.map((transfer) => _buildTransferItem(
          transfer['name'] as String,
          transfer['initials'] as String,
          transfer['amount'] as String,
          transfer['date'] as String,
          isAsset: transfer['isAsset'] as bool,
        )).toList(),
      ],
    );
  }

  Widget _buildTransferItem(String name, String initialsOrPath, String amount, String date,
      {bool isAsset = false}) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1A1A2E).withOpacity(0.8),
              const Color(0xFF16213E).withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF00FFFF).withOpacity(_glowAnimation.value * 0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00FFFF).withOpacity(_glowAnimation.value * 0.2),
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
                  colors: [Color(0xFF00FFFF), Color(0xFFFF00FF)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00FFFF).withOpacity(0.5),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: isAsset
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  initialsOrPath,
                  fit: BoxFit.cover,
                ),
              )
                  : Center(
                child: Text(
                  initialsOrPath,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
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
                  Text(
                    name.toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF00FFFF),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$amount - QUANTUM TRANSFER COMPLETE",
                    style: const TextStyle(
                      color: Color(0xFF808080),
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  date,
                  style: const TextStyle(
                    color: Color(0xFF808080),
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00FF00), Color(0xFF80FF00)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00FF00).withOpacity(0.5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantumFAB() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) => Transform.scale(
        scale: _pulseAnimation.value,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00FFFF), Color(0xFFFF00FF)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00FFFF).withOpacity(0.6),
                blurRadius: 25,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            onPressed: () {},
            backgroundColor: Colors.transparent,
            elevation: 0,
            label: const Text(
              "NEW QUANTUM TRANSFER",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            icon: const Icon(
              Icons.add,
              color: Colors.black,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}