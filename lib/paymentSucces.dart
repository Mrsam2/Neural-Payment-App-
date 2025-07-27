import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'firebase_service.dart';
import 'firebase_balance_service.dart';
import 'payment_success_detail.dart';
import 'upi_name_service.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final String title;
  final String subtitle;
  final String amount;
  final String bankName;
  final String accountNumber;

  const PaymentSuccessScreen({
    super.key,
    required this.title,
    required this.amount,
    required this.bankName,
    required this.subtitle,
    required this.accountNumber, required Map transactionData,
  });

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> with TickerProviderStateMixin {
  String? transactionDocumentId;
  bool isStoringTransaction = true;
  String? generatedRRN;
  String? displayName;
  bool isLoadingName = true;

  late AnimationController _glowController;
  late AnimationController _celebrationController;
  late Animation<double> _glowAnimation;
  late Animation<double> _celebrationAnimation;
  late Animation<double> _scaleAnimation;

  final String smsNumber = "";

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _fetchDisplayName();
    _storeTransactionInFirebase();
  }

  void _setupAnimations() {
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _celebrationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _celebrationController, curve: Curves.elasticOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _celebrationController, curve: Curves.easeInOut),
    );

    _glowController.repeat(reverse: true);
    _celebrationController.forward();
  }

  @override
  void dispose() {
    _glowController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  Future<void> _fetchDisplayName() async {
    try {
      final name = await UpiNameService.getNameByUpiId(widget.subtitle);
      setState(() {
        displayName = name;
        isLoadingName = false;
      });
    } catch (e) {
      print('Error fetching display name: $e');
      setState(() {
        isLoadingName = false;
      });
    }
  }

  String getDisplayTitle() {
    if (displayName != null && displayName!.isNotEmpty) {
      return displayName!;
    }
    return widget.title;
  }

  Future<void> _storeTransactionInFirebase() async {
    try {
      final documentId = await FirebaseService.storePaymentTransaction(
        title: getDisplayTitle(),
        upiId: widget.subtitle,
        amount: widget.amount,
        bankName: widget.bankName,
        accountNumber: widget.accountNumber,
      );

      setState(() {
        transactionDocumentId = documentId;
        isStoringTransaction = false;
      });

      _deductFromBalanceInBackground(documentId);
      _generateRRNAndSendSMS();
    } catch (e) {
      setState(() {
        isStoringTransaction = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to store neural transaction: $e'),
          backgroundColor: const Color(0xFFFF0040),
        ),
      );
    }
  }

  Future<void> _deductFromBalanceInBackground(String transactionId) async {
    try {
      final paymentAmount = double.parse(widget.amount);

      await FirebaseBalanceService.deductFromBalance(
        amount: paymentAmount,
        transactionId: transactionId,
        merchantName: getDisplayTitle(),
        upiId: widget.subtitle,
      );

      print('Neural balance deducted successfully: ₹$paymentAmount');
    } catch (e) {
      print('Neural balance deduction failed: $e');
    }
  }

  String _generateRRN() {
    final random = Random();
    String rrn = '';
    for (int i = 0; i < 14; i++) {
      rrn += random.nextInt(10).toString();
    }
    return rrn;
  }

  Future<void> _generateRRNAndSendSMS() async {
    generatedRRN = _generateRRN();
    await _sendBankSMS();
    setState(() {});
  }

  Future<void> _sendBankSMS() async {
    try {
      final now = DateTime.now();
      final formattedDate = DateFormat('dd-MMM-yy').format(now);
      final bankMessage = _generateBankSMS(formattedDate);

      await _sendSMSViaURLLauncher(smsNumber, bankMessage);
      print('Neural SMS transmission successful');
    } catch (e) {
      print('Neural SMS Error: $e');
    }
  }

  Future<void> _sendSMSViaURLLauncher(String phoneNumber, String message) async {
    try {
      final Uri smsUri = Uri(
        scheme: 'sms',
        path: phoneNumber,
        queryParameters: {'body': message},
      );

      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
        print('Neural SMS interface opened successfully');
      } else {
        print('Could not open neural SMS interface');
        final Uri simpleSmsUri = Uri(scheme: 'sms', path: phoneNumber);
        if (await canLaunchUrl(simpleSmsUri)) {
          await launchUrl(simpleSmsUri);
          print('Neural SMS interface opened without pre-filled message');
        }
      }
    } catch (e) {
      print('Error opening neural SMS interface: $e');
    }
  }

  String _generateBankSMS(String date) {
    return 'Neural A/c X8217 debited by Rs. ${widget.amount}.00 for quantum UPI transfer to ${getDisplayTitle()} on $date. RRN: $generatedRRN if not authorized, contact neural support 18002334526 -Bank of Maharashtra Neural Division';
  }

  void _navigateToTransactionDetails() {
    if (transactionDocumentId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentSuccessDetailPage(
            transactionDocumentId: transactionDocumentId!,
            transaction: {},
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Neural transaction details not available yet'),
          backgroundColor: const Color(0xFFFF8000),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final formattedDate = DateFormat('dd MMM yyyy at hh:mm a').format(now);
    final currentDisplayTitle = getDisplayTitle();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          // Cyberpunk Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF00FF00).withOpacity(0.3),
                  const Color(0xFF00FFFF).withOpacity(0.2),
                  const Color(0xFF0A0A0A),
                  const Color(0xFF0A0A0A),
                ],
                stops: const [0.0, 0.3, 0.6, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 40),
                          _buildSuccessAnimation(),
                          const SizedBox(height: 20),
                          _buildSuccessTitle(formattedDate),
                          const SizedBox(height: 40),
                          _buildTransactionCard(currentDisplayTitle),
                          const SizedBox(height: 30),
                          _buildCyberpunkImageSlider(),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildDoneButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessAnimation() {
    return AnimatedBuilder(
      animation: _celebrationAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                const Color(0xFF00FF00).withOpacity(_celebrationAnimation.value),
                const Color(0xFF00FFFF).withOpacity(_celebrationAnimation.value * 0.8),
                Colors.transparent,
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00FF00), Color(0xFF00FFFF)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00FF00).withOpacity(0.6),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: const Icon(
                Icons.check,
                color: Colors.black,
                size: 60,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessTitle(String formattedDate) {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF00FF00), Color(0xFF00FFFF)],
          ).createShader(bounds),
          child: const Text(
            'QUANTUM TRANSFER COMPLETE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          formattedDate.toUpperCase(),
          style: TextStyle(
            color: const Color(0xFF00FFFF).withOpacity(0.8),
            fontSize: 14,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionCard(String currentDisplayTitle) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) => Container(
        width: double.infinity,
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
            color: Color.lerp(const Color(0xFF00FF00), const Color(0xFF00FFFF), _glowAnimation.value)!,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Color.lerp(const Color(0xFF00FF00), const Color(0xFF00FFFF), _glowAnimation.value)!.withOpacity(0.4),
              blurRadius: 25,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00FFFF), Color(0xFFFF00FF)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00FFFF).withOpacity(0.5),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: isLoadingName
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 2,
                      ),
                    )
                        : const Icon(
                      Icons.person_outline,
                      color: Colors.black,
                      size: 35,
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
                            currentDisplayTitle.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.subtitle,
                          style: const TextStyle(
                            color: Color(0xFF00FFFF),
                            fontSize: 14,
                            letterSpacing: 0.5,
                          ),
                        ),
                        if (generatedRRN != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            'NEURAL RRN: $generatedRRN',
                            style: const TextStyle(
                              color: Color(0xFF808080),
                              fontSize: 12,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF00FF00), Color(0xFF00FFFF)],
                    ).createShader(bounds),
                    child: Text(
                      '₹${widget.amount}.00',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF00FF), Color(0xFFFF0080)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF00FF).withOpacity(0.5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const Text(
                      'SPLIT EXPENSE',
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
            const SizedBox(height: 24),
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    const Color(0xFF00FFFF).withOpacity(0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.receipt_outlined,
                      label: 'VIEW DETAILS',
                      isLoading: isStoringTransaction,
                      onPressed: _navigateToTransactionDetails,
                    ),
                  ),
                  Container(
                    width: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          const Color(0xFF00FFFF).withOpacity(0.5),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.share,
                      label: 'SHARE RECEIPT',
                      onPressed: _shareTransactionDetails,
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isLoading = false,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Container(
        width: 40,
        height: 40,
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
        child: isLoading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            color: Colors.black,
            strokeWidth: 2,
          ),
        )
            : Icon(
          icon,
          color: Colors.black,
          size: 20,
        ),
      ),
      label: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF00FFFF),
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildCyberpunkImageSlider() {
    return const CyberpunkImageSliderBanner();
  }

  Widget _buildDoneButton() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) => GestureDetector(
        onTap: () {
          Navigator.popUntil(context, (route) => route.isFirst);
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.lerp(const Color(0xFF00FFFF), const Color(0xFFFF00FF), _glowAnimation.value)!,
                Color.lerp(const Color(0xFFFF00FF), const Color(0xFF00FFFF), _glowAnimation.value)!,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Color.lerp(const Color(0xFF00FFFF), const Color(0xFFFF00FF), _glowAnimation.value)!.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: const Text(
            'NEURAL LINK COMPLETE',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }

  void _shareTransactionDetails() {
    final shareText = '''
🔥 QUANTUM TRANSFER COMPLETE! 🔥
Amount: ₹${widget.amount}
To: ${getDisplayTitle()}
Neural ID: ${widget.subtitle}
RRN: ${generatedRRN ?? 'Generating...'}
Timestamp: ${DateFormat('dd MMM yyyy at hh:mm a').format(DateTime.now())}
    ''';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Neural transaction details copied to quantum clipboard'),
        backgroundColor: const Color(0xFF00FF00),
      ),
    );
  }
}

class CyberpunkImageSliderBanner extends StatefulWidget {
  const CyberpunkImageSliderBanner({super.key});

  @override
  _CyberpunkImageSliderBannerState createState() => _CyberpunkImageSliderBannerState();
}

class _CyberpunkImageSliderBannerState extends State<CyberpunkImageSliderBanner> with TickerProviderStateMixin {
  final PageController _controller = PageController();
  int _currentPage = 0;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  final List<String> _imagePaths = [
    'assets/b4.jpg',
    'assets/b5.jpg',
  ];

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

    Timer.periodic(const Duration(seconds: 5), (timer) {
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
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) => Container(
            height: 200,
            margin: const EdgeInsets.symmetric(horizontal: 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF00FFFF).withOpacity(_glowAnimation.value * 0.8),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00FFFF).withOpacity(_glowAnimation.value * 0.3),
                  blurRadius: 20,
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
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_imagePaths.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 8,
              width: _currentPage == index ? 24 : 8,
              decoration: BoxDecoration(
                gradient: _currentPage == index
                    ? const LinearGradient(
                  colors: [Color(0xFF00FFFF), Color(0xFFFF00FF)],
                )
                    : null,
                color: _currentPage == index ? null : const Color(0xFF808080),
                borderRadius: BorderRadius.circular(4),
                boxShadow: _currentPage == index
                    ? [
                  BoxShadow(
                    color: const Color(0xFF00FFFF).withOpacity(0.5),
                    blurRadius: 10,
                  ),
                ]
                    : null,
              ),
            );
          }),
        ),
      ],
    );
  }
}