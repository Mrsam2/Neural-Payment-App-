import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'checkBalence.dart';
import 'dart:math' as math;

class PaymentSuccessDetailPage extends StatefulWidget {
  final Map<String, dynamic> transaction;
  final String transactionDocumentId;

  const PaymentSuccessDetailPage({
    Key? key,
    required this.transaction,
    required this.transactionDocumentId,
  }) : super(key: key);

  @override
  State<PaymentSuccessDetailPage> createState() => _PaymentSuccessDetailPageState();
}

class _PaymentSuccessDetailPageState extends State<PaymentSuccessDetailPage>
    with TickerProviderStateMixin {
  bool isTransferDetailsExpanded = true;
  Map<String, dynamic>? fullTransactionData;
  bool isLoading = true;
  String? errorMessage;

  // Animation controllers
  late AnimationController _glowController;
  late AnimationController _pulseController;
  late AnimationController _scanController;
  late AnimationController _matrixController;
  late Animation<double> _glowAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scanAnimation;
  late Animation<double> _matrixAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadFullTransactionData();
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

    _glowController.repeat(reverse: true);
    _pulseController.repeat(reverse: true);
    _scanController.repeat();
    _matrixController.repeat();
  }

  @override
  void dispose() {
    _glowController.dispose();
    _pulseController.dispose();
    _scanController.dispose();
    _matrixController.dispose();
    super.dispose();
  }

  Future<void> _loadFullTransactionData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final source = widget.transaction['source'] ?? 'payment';
      final docId = widget.transactionDocumentId;

      print('Loading neural transaction - Source: $source, DocId: $docId');

      DocumentSnapshot? doc;
      Map<String, dynamic>? fetchedData;

      // Try to fetch from the specified source first
      if (source == 'history') {
        try {
          doc = await FirebaseFirestore.instance
              .collection('payment_history')
              .doc(docId)
              .get();

          if (doc.exists) {
            fetchedData = doc.data() as Map<String, dynamic>;
            print('Successfully fetched from neural payment_history');
          }
        } catch (e) {
          print('Error fetching from neural payment_history: $e');
        }
      } else {
        try {
          doc = await FirebaseFirestore.instance
              .collection('payment_transactions')
              .doc(docId)
              .get();

          if (doc.exists) {
            fetchedData = doc.data() as Map<String, dynamic>;
            print('Successfully fetched from neural payment_transactions');
          }
        } catch (e) {
          print('Error fetching from neural payment_transactions: $e');
        }
      }

      // If first attempt failed, try the other collection
      if (fetchedData == null) {
        print('First attempt failed, trying alternative neural collection...');

        if (source == 'history') {
          try {
            doc = await FirebaseFirestore.instance
                .collection('payment_transactions')
                .doc(docId)
                .get();

            if (doc.exists) {
              fetchedData = doc.data() as Map<String, dynamic>;
              print('Successfully fetched from neural payment_transactions (fallback)');
            }
          } catch (e) {
            print('Error fetching from neural payment_transactions (fallback): $e');
          }
        } else {
          try {
            doc = await FirebaseFirestore.instance
                .collection('payment_history')
                .doc(docId)
                .get();

            if (doc.exists) {
              fetchedData = doc.data() as Map<String, dynamic>;
              print('Successfully fetched from neural payment_history (fallback)');
            }
          } catch (e) {
            print('Error fetching from neural payment_history (fallback): $e');
          }
        }
      }

      if (fetchedData != null) {
        final normalizedData = _normalizeTransactionData(fetchedData);

        setState(() {
          fullTransactionData = {
            ...widget.transaction,
            ...normalizedData,
            'id': doc!.id,
            'source': source,
          };
          isLoading = false;
        });

        print('Neural transaction data loaded successfully');
      } else {
        setState(() {
          fullTransactionData = _normalizeTransactionData(widget.transaction);
          isLoading = false;
          errorMessage = 'Using cached neural transaction data';
        });

        print('Using original neural transaction data as fallback');
      }
    } catch (e) {
      print('Error loading neural transaction data: $e');
      setState(() {
        fullTransactionData = _normalizeTransactionData(widget.transaction);
        isLoading = false;
        errorMessage = 'Error loading neural data: $e';
      });
    }
  }

  Map<String, dynamic> _normalizeTransactionData(Map<String, dynamic> data) {
    return {
      'name': data['name'] ?? data['title'] ?? 'Unknown Neural Entity',
      'title': data['title'] ?? data['name'] ?? 'Unknown Neural Entity',
      'upi_id': data['upi_id'] ?? data['upiId'] ?? '',
      'upiId': data['upiId'] ?? data['upi_id'] ?? '',
      'transaction_id': data['transaction_id'] ?? data['transactionId'] ?? 'N/A',
      'transactionId': data['transactionId'] ?? data['transaction_id'] ?? 'N/A',
      'amount': data['amount']?.toString() ?? '0',
      'type': data['type'] ?? 'paid_to',
      'timestamp': data['timestamp'],
      'bankName': data['bankName'] ?? 'Bank Of Maharashtra',
      'accountNumber': data['accountNumber'] ?? 'XXXXXXX8287',
      'status': data['status'] ?? 'Neural Success',
      'prepaid_reference_id': data['prepaid_reference_id'],
      'operator': data['operator'] ?? data['name'] ?? data['title'],
      'mobile_number': data['mobile_number'] ?? data['upi_id'] ?? data['upiId'],
      'utr': data['utr'] ?? _generateQuantumUTR(),
      'banking_name': data['banking_name'] ?? '${data['name'] ?? data['title'] ?? 'Unknown Neural Entity'} ',
      ...data,
    };
  }

  String _generateQuantumUTR() {
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    return 'QTM${random.substring(random.length - 9)}';
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.black),
            SizedBox(width: 8),
            Text('$label copied to neural clipboard'),
          ],
        ),
        backgroundColor: const Color(0xFF00FF00),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: Duration(seconds: 2),
      ),
    );
  }

  String _getHeaderTitle() {
    final type = fullTransactionData?['type'] ?? 'paid_to';
    switch (type) {
      case 'received_from':
        return 'NEURAL TRANSFER SUCCESSFUL';
      case 'mobile_recharge':
        return 'ENERGY RECHARGE SUCCESSFUL';
      case 'paid_to':
      default:
        return 'TRANSACTION SUCCESSFUL';
    }
  }

  String _getMainTitle() {
    final type = fullTransactionData?['type'] ?? 'paid_to';
    switch (type) {
      case 'received_from':
        return 'Neural credits received from';
      case 'mobile_recharge':
        return 'Energy boost transmitted to';
      case 'paid_to':
      default:
        return 'credits transferred to';
    }
  }

  DateTime _getTransactionDateTime() {
    final timestamp = fullTransactionData?['timestamp'];
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is String) {
      try {
        return DateTime.parse(timestamp);
      } catch (e) {
        return DateTime.now();
      }
    } else if (timestamp is int) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    return DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        body: Container(
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
          child: Stack(
            children: [
              // Matrix background
              _buildMatrixBackground(),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Holographic loading indicator
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
                                Colors.transparent,
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00FFFF).withOpacity(0.8),
                                blurRadius: 30,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                            strokeWidth: 3,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF00FFFF), Color(0xFFFF00FF)],
                      ).createShader(bounds),
                      child: const Text(
                        'LOADING NEURAL TRANSACTION DATA...',
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
              ),
            ],
          ),
        ),
      );
    }

    if (fullTransactionData == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        body: Container(
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
          child: Stack(
            children: [
              _buildMatrixBackground(),
              SafeArea(
                child: Column(
                  children: [
                    // Cyberpunk app bar
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(12),
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
                              child: const Icon(Icons.arrow_back, color: Color(0xFF00FFFF)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFF00FFFF), Color(0xFFFF00FF)],
                            ).createShader(bounds),
                            child: const Text(
                              'NEURAL TRANSACTION DETAILS',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFF0040), Color(0xFFFF8000)],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFF0040).withOpacity(0.5),
                                    blurRadius: 30,
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.error_outline, color: Colors.black, size: 50),
                            ),
                            const SizedBox(height: 24),
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [Color(0xFFFF0040), Color(0xFFFF8000)],
                              ).createShader(bounds),
                              child: const Text(
                                'NEURAL DATA LINK FAILED',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (errorMessage != null)
                              Text(
                                errorMessage!,
                                style: const TextStyle(
                                  color: Color(0xFF808080),
                                  fontSize: 14,
                                  letterSpacing: 1,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            const SizedBox(height: 32),
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
                                onPressed: () => _loadFullTransactionData(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  child: Text(
                                    'RETRY NEURAL LINK',
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

    final transaction = fullTransactionData!;
    final type = transaction['type'] ?? 'paid_to';
    final transactionDateTime = _getTransactionDateTime();
    final formattedDate = DateFormat('hh:mm a \'on\' dd MMM yyyy').format(transactionDateTime);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Container(
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
        child: Stack(
          children: [
            _buildMatrixBackground(),
            SafeArea(
              child: Column(
                children: [
                  // Cyberpunk success header
                  _buildCyberpunkHeader(formattedDate),

                  // Main content
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 32),

                          // Main title section
                          _buildMainTitleSection(),

                          const SizedBox(height: 24),

                          // Transaction details
                          _buildTransactionDetailsSection(transaction, type),

                          const SizedBox(height: 32),

                          // Banking section for received payments
                          if (type == 'received_from') ...[
                            _buildBankingSection(transaction),
                            const SizedBox(height: 32),
                          ],

                          // Transfer details section
                          _buildTransferDetailsSection(transaction, type),

                          const SizedBox(height: 40),

                          // Action buttons
                          _buildActionButtonsSection(type),

                          const SizedBox(height: 40),

                          // Contact support
                          _buildContactSupportSection(),

                          const SizedBox(height: 40),

                          // Powered by section
                          _buildPoweredBySection(),

                          const SizedBox(height: 40),
                        ],
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

  Widget _buildCyberpunkHeader(String formattedDate) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) => Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.lerp(const Color(0xFF00FF00), const Color(0xFF00FFFF), _glowAnimation.value)!,
              Color.lerp(const Color(0xFF00FFFF), const Color(0xFF00FF00), _glowAnimation.value)!,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00FF00).withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getHeaderTitle(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'NEURAL TIMESTAMP: $formattedDate',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.8),
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            // Success indicator
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: Colors.black, size: 24),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainTitleSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AnimatedBuilder(
        animation: _scanAnimation,
        builder: (context, child) => ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              Color.lerp(const Color(0xFF00FFFF), const Color(0xFFFF00FF), _scanAnimation.value)!,
              Color.lerp(const Color(0xFFFF00FF), const Color(0xFF00FFFF), _scanAnimation.value)!,
            ],
          ).createShader(bounds),
          child: Text(
            _getMainTitle().toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionDetailsSection(Map<String, dynamic> transaction, String type) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AnimatedBuilder(
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
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Color.lerp(const Color(0xFF00FFFF), const Color(0xFFFF00FF), _glowAnimation.value)!.withOpacity(0.8),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Color.lerp(const Color(0xFF00FFFF), const Color(0xFFFF00FF), _glowAnimation.value)!.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            children: [
              // Neural avatar
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) => Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: type == 'mobile_recharge'
                          ? const LinearGradient(colors: [Color(0xFFFFFF00), Color(0xFFFF8000)])
                          : type == 'received_from'
                          ? const LinearGradient(colors: [Color(0xFF00FF00), Color(0xFF00FFFF)])
                          : const LinearGradient(colors: [Color(0xFFFF00FF), Color(0xFF8000FF)]),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: (type == 'mobile_recharge'
                              ? const Color(0xFFFFFF00)
                              : type == 'received_from'
                              ? const Color(0xFF00FF00)
                              : const Color(0xFFFF00FF)).withOpacity(0.6),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Center(
                      child: type == 'mobile_recharge'
                          ? const Icon(Icons.smartphone, color: Colors.black, size: 32)
                          : type == 'received_from'
                          ? const Icon(Icons.south_west, color: Colors.black, size: 32)
                          : const Icon(Icons.north_east, color: Colors.black, size: 32),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type == 'mobile_recharge'
                          ? (transaction['operator'] ?? 'Neural Energy Provider')
                          : (transaction['name'] ?? transaction['title'] ?? 'Unknown Neural Entity'),
                      style: const TextStyle(
                        color: Color(0xFF00FFFF),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      type == 'mobile_recharge'
                          ? 'NEURAL ID: ${transaction['mobile_number'] ?? transaction['upi_id'] ?? ''}'
                          : 'ID: +${transaction['mobile'] ?? transaction['upi_id'] ?? '918669884370'}',
                      style: const TextStyle(
                        color: Color(0xFF808080),
                        fontSize: 14,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF00FF00), Color(0xFF00FFFF)],
                ).createShader(bounds),
                child: Text(
                  '₹${transaction['amount']}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBankingSection(Map<String, dynamic> transaction) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1A1A2E).withOpacity(0.6),
              const Color(0xFF16213E).withOpacity(0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF00FF00).withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            const Text(
              'NEURAL BANKING ENTITY',
              style: TextStyle(
                color: Color(0xFF808080),
                fontSize: 14,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              ':',
              style: TextStyle(
                color: Color(0xFF808080),
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                transaction['banking_name'] ?? '${transaction['name'] ?? 'Unknown Neural Entity'} ',
                style: const TextStyle(
                  color: Color(0xFF00FFFF),
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00FF00), Color(0xFF00FFFF)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.black, size: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransferDetailsSection(Map<String, dynamic> transaction, String type) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) => Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1A1A2E).withOpacity(0.8),
                const Color(0xFF16213E).withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Color.lerp(const Color(0xFF00FFFF), const Color(0xFFFF00FF), _glowAnimation.value)!.withOpacity(0.6),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Color.lerp(const Color(0xFF00FFFF), const Color(0xFFFF00FF), _glowAnimation.value)!.withOpacity(0.2),
                blurRadius: 15,
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              GestureDetector(
                onTap: () {
                  setState(() {
                    isTransferDetailsExpanded = !isTransferDetailsExpanded;
                  });
                  HapticFeedback.lightImpact();
                },
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00FFFF), Color(0xFFFF00FF)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.receipt_outlined, color: Colors.black, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      type == 'mobile_recharge' ? 'NEURAL ENERGY DETAILS' : 'TRANSFER DETAILS',
                      style: const TextStyle(
                        color: Color(0xFF00FFFF),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const Spacer(),
                    AnimatedRotation(
                      turns: isTransferDetailsExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Color(0xFF00FFFF),
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),

              if (isTransferDetailsExpanded) ...[
                const SizedBox(height: 24),

                // Transaction ID
                _buildDetailRow(
                  'NEURAL TRANSACTION ID',
                  transaction['transaction_id'] ?? transaction['transactionId'] ?? 'N/A',
                  true,
                ),

                // Mobile recharge specific fields
                if (type == 'mobile_recharge' && transaction['prepaid_reference_id'] != null) ...[
                  const SizedBox(height: 20),
                  _buildDetailRow(
                    'ENERGY PROVIDER REFERENCE ID',
                    transaction['prepaid_reference_id'],
                    true,
                  ),
                ],

                const SizedBox(height: 24),

                // Account section
                _buildAccountSection(transaction, type),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool copyable) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF808080),
            fontSize: 12,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF00FFFF),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            if (copyable)
              GestureDetector(
                onTap: () => _copyToClipboard(value, label),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF00FF), Color(0xFF8000FF)],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.copy,
                    color: Colors.black,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildAccountSection(Map<String, dynamic> transaction, String type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          type == 'received_from' ? 'NEURAL CREDITS RECEIVED TO' : 'CREDITS DEBITED FROM',
          style: const TextStyle(
            color: Color(0xFF808080),
            fontSize: 12,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF2A2A3E).withOpacity(0.6),
                const Color(0xFF26234E).withOpacity(0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF00FF00).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Bank logo
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
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: Center(
                  child: Image.asset("assets/b7.png", width: 30, height: 30),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ACCOUNT: ${transaction['accountNumber'] ?? 'XXXXXXX8287'}',
                      style: const TextStyle(
                        color: Color(0xFF00FFFF),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'QTM-UTR: ${transaction['utr']}',
                          style: const TextStyle(
                            color: Color(0xFF808080),
                            fontSize: 12,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _copyToClipboard(
                              transaction['utr'],
                              'UTR'
                          ),
                          child: const Icon(
                            Icons.copy,
                            color: Color(0xFFFF00FF),
                            size: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF00FF00), Color(0xFF00FFFF)],
                ).createShader(bounds),
                child: Text(
                  '₹${transaction['amount']}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtonsSection(String type) {
    final actions = type == 'mobile_recharge'
        ? [
      {'icon': Icons.history, 'label': 'NEURAL\nHISTORY', 'onTap': () => Navigator.pop(context)},
      {'icon': Icons.flash_on, 'label': 'ENERGY\nBOOST', 'onTap': () => _showComingSoon('Energy Boost')},
      {'icon': Icons.call_split, 'label': 'SPLIT\nCOST', 'onTap': () => _showComingSoon('Split Cost')},
      {'icon': Icons.share, 'label': 'SHARE\nDATA', 'onTap': _shareTransactionDetails},
    ]
        : [
      {'icon': Icons.north_east, 'label': 'SEND\nCREDITS', 'onTap': () => _showComingSoon('Send Credits')},
      {'icon': Icons.account_balance, 'label': 'CHECK\nBALANCE', 'onTap': () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CheckBalancePage()),
        );
      }},
      {'icon': Icons.history, 'label': 'NEURAL\nHISTORY', 'onTap': () => Navigator.pop(context)},
      {'icon': Icons.share, 'label': 'SHARE\nDATA', 'onTap': _shareTransactionDetails},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: actions.map((action) => _buildCyberpunkActionButton(
          icon: action['icon'] as IconData,
          label: action['label'] as String,
          onTap: action['onTap'] as VoidCallback,
        )).toList(),
      ),
    );
  }

  Widget _buildCyberpunkActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) => Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8000FF), Color(0xFFFF00FF)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8000FF).withOpacity(0.6),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.black,
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF00FFFF),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContactSupportSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A1A2E).withOpacity(0.6),
            const Color(0xFF16213E).withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF808080).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF808080), Color(0xFF606060)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.support_agent, color: Colors.black, size: 24),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'CONTACT NEURAL SUPPORT',
              style: TextStyle(
                color: Color(0xFF00FFFF),
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF808080), size: 24),
        ],
      ),
    );
  }

  Widget _buildPoweredBySection() {
    return Center(
      child: Column(
        children: [
          const Text(
            'POWERED BY NEURAL NETWORK',
            style: TextStyle(
              color: Color(0xFF808080),
              fontSize: 12,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00FFFF), Color(0xFFFF00FF)],
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00FFFF).withOpacity(0.3),
                  blurRadius: 15,
                ),
              ],
            ),
            child: Image.asset("assets/p6.png", width: 60),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info, color: Colors.black),
            SizedBox(width: 8),
            Text('$feature neural protocol coming soon!'),
          ],
        ),
        backgroundColor: const Color(0xFF00FFFF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _shareTransactionDetails() {
    final transaction = fullTransactionData!;
    final type = transaction['type'] ?? 'paid_to';
    final transactionDateTime = _getTransactionDateTime();
    final shareText = '''
${_getHeaderTitle()} ✅

NEURAL AMOUNT: ₹${transaction['amount']}
${type == 'received_from' ? 'FROM NEURAL ENTITY' : type == 'mobile_recharge' ? 'ENERGY PROVIDER' : 'TO NEURAL ENTITY'}: ${type == 'mobile_recharge' ? (transaction['operator'] ?? 'Neural Energy Provider') : (transaction['name'] ?? transaction['title'])}
${type == 'mobile_recharge' ? 'NEURAL ID' : 'ID'}: ${type == 'mobile_recharge' ? (transaction['mobile_number'] ?? transaction['upi_id']) : '+${transaction['mobile'] ?? transaction['upi_id']}'}
NEURAL TRANSACTION ID: ${transaction['transaction_id'] ?? transaction['transactionId'] ?? 'N/A'}
NEURAL TIMESTAMP: ${DateFormat('dd MMM yyyy at hh:mm a').format(transactionDateTime)}UTR: ${transaction['utr'] ?? 'N/A'}

${type == 'received_from' ? 'CREDITED TO' : 'DEBITED FROM'} ACCOUNT ${transaction['accountNumber'] ?? 'XXXXXXX8287'}

🔮 POWERED BY NEURAL NETWORK
    ''';

    _copyToClipboard(shareText, 'Neural transaction details');
  }
}

// Custom painter for matrix background effect
class MatrixPainter extends CustomPainter {
  final double animationValue;

  MatrixPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00FFFF).withOpacity(0.1)
      ..strokeWidth = 1;

    for (int i = 0; i < 15; i++) {
      final x = (size.width / 15) * i;
      final y = (animationValue * size.height * 2) % (size.height + 100) - 100;

      canvas.drawLine(
        Offset(x, y),
        Offset(x, y + 60),
        paint,
      );
    }

    // Add some circuit-like patterns
    final circuitPaint = Paint()
      ..color = const Color(0xFFFF00FF).withOpacity(0.05)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 8; i++) {
      final startX = (size.width / 8) * i;
      final startY = size.height * 0.2;

      final path = Path();
      path.moveTo(startX, startY);
      path.lineTo(startX + 30, startY);
      path.lineTo(startX + 30, startY + 40);
      path.lineTo(startX + 60, startY + 40);

      canvas.drawPath(path, circuitPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}