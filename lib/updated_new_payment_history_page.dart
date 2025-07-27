import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class NewPaymentHistoryPage extends StatefulWidget {
  final String? initialPaymentType;

  const NewPaymentHistoryPage({
    super.key,
    this.initialPaymentType,
  });

  @override
  State<NewPaymentHistoryPage> createState() => _NewPaymentHistoryPageState();
}

class _NewPaymentHistoryPageState extends State<NewPaymentHistoryPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _upiController = TextEditingController();
  final _amountController = TextEditingController();
  final _prepaidReferenceController = TextEditingController();

  String _selectedType = 'paid_to';
  bool _isLoading = false;
  String _generatedTransactionId = '';

  late AnimationController _glowController;
  late AnimationController _pulseController;
  late AnimationController _scanController;
  late Animation<double> _glowAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scanAnimation;

  final List<Map<String, String>> _paymentTypes = [
    {'value': 'paid_to', 'label': 'Neural Transfer Out'},
    {'value': 'received_from', 'label': 'Quantum Credits In'},
    {'value': 'mobile_recharge', 'label': 'Neural Mobile Boost'},
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _generateTransactionId();

    if (widget.initialPaymentType != null) {
      _selectedType = widget.initialPaymentType!;
      if (_selectedType == 'mobile_recharge') {
        _generatePrepaidReference();
      }
    }
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
    _glowController.dispose();
    _pulseController.dispose();
    _scanController.dispose();
    _nameController.dispose();
    _upiController.dispose();
    _amountController.dispose();
    _prepaidReferenceController.dispose();
    super.dispose();
  }

  void _generateTransactionId() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    _generatedTransactionId = 'NTX$timestamp${random.nextInt(9999).toString().padLeft(4, '0')}';
  }

  void _generatePrepaidReference() {
    if (_selectedType == 'mobile_recharge') {
      final random = Random();
      final reference = random.nextInt(999999999) + 100000000;
      _prepaidReferenceController.text = reference.toString();
    }
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final transactionData = {
        'type': _selectedType,
        'title': _nameController.text.trim(),
        'name': _nameController.text.trim(),
        'upiId': _upiController.text.trim(),
        'upi_id': _upiController.text.trim(),
        'amount': double.parse(_amountController.text),
        'transactionId': _generatedTransactionId,
        'timestamp': Timestamp.now(),
        'status': 'completed',
        'bankName': 'Neural Bank Of Maharashtra',
        'accountNumber': '••••8287',
      };

      if (_selectedType == 'mobile_recharge') {
        transactionData['prepaidReference'] = _prepaidReferenceController.text;
        transactionData['operator'] = 'Neural Airtel Prepaid';
        transactionData['mobileNumber'] = _upiController.text;
      }

      await FirebaseFirestore.instance
          .collection('payment_transactions')
          .add(transactionData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Neural transaction saved to quantum database!'),
          backgroundColor: const Color(0xFF00FF00),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

      Navigator.pop(context, true);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Neural sync error: $e'),
          backgroundColor: const Color(0xFFFF0040),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
          child: Column(
            children: [
              _buildCyberpunkAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPaymentTypeSection(),
                        const SizedBox(height: 24),
                        _buildNameSection(),
                        const SizedBox(height: 24),
                        _buildUpiSection(),
                        const SizedBox(height: 24),
                        _buildTransactionIdSection(),
                        const SizedBox(height: 24),
                        _buildAmountSection(),
                        if (_selectedType == 'mobile_recharge') ...[
                          const SizedBox(height: 24),
                          _buildPrepaidReferenceSection(),
                        ],
                        const SizedBox(height: 24),
                        _buildDefaultInfoSection(),
                        const SizedBox(height: 40),
                        _buildSaveButton(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
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
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F3460),
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
                  "NEURAL TRANSACTION CREATOR",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
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

  Widget _buildPaymentTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF00FFFF), Color(0xFFFF00FF)],
          ).createShader(bounds),
          child: const Text(
            'SELECT NEURAL PROTOCOL',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 12),
        AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1A1A2E).withOpacity(0.8),
                  const Color(0xFF16213E).withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF00FFFF).withOpacity(0.8),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00FFFF).withOpacity(0.3),
                  blurRadius: 15,
                ),
              ],
            ),
            child: DropdownButtonFormField<String>(
              value: _selectedType,
              dropdownColor: const Color(0xFF1A1A2E),
              style: const TextStyle(color: Color(0xFF00FFFF)),
              decoration: const InputDecoration(
                border: InputBorder.none,
                icon: Icon(Icons.memory, color: Color(0xFF00FFFF)),
              ),
              items: _paymentTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type['value'],
                  child: Text(
                    type['label']!,
                    style: const TextStyle(
                      color: Color(0xFF00FFFF),
                      letterSpacing: 0.5,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                  if (value == 'mobile_recharge') {
                    _generatePrepaidReference();
                  } else {
                    _prepaidReferenceController.clear();
                  }
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNameSection() {
    return _buildCyberpunkTextField(
      controller: _nameController,
      label: _selectedType == 'mobile_recharge' ? 'NEURAL OPERATOR' : 'TARGET ENTITY',
      hint: _selectedType == 'mobile_recharge' ? 'e.g., Neural Airtel Prepaid' : 'Enter target name',
      icon: Icons.person,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Neural entity name required';
        }
        return null;
      },
    );
  }

  Widget _buildUpiSection() {
    return _buildCyberpunkTextField(
      controller: _upiController,
      label: _selectedType == 'mobile_recharge' ? 'NEURAL MOBILE ID' : 'QUANTUM UPI ADDRESS',
      hint: _selectedType == 'mobile_recharge' ? 'Enter neural mobile number' : 'Enter quantum UPI ID',
      icon: _selectedType == 'mobile_recharge' ? Icons.phone_android : Icons.account_balance_wallet,
      keyboardType: _selectedType == 'mobile_recharge' ? TextInputType.phone : TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return _selectedType == 'mobile_recharge' ? 'Neural mobile ID required' : 'Quantum UPI address required';
        }
        if (_selectedType == 'mobile_recharge' && value.length != 10) {
          return 'Neural mobile ID must be 10 digits';
        }
        return null;
      },
    );
  }

  Widget _buildTransactionIdSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF00FFFF), Color(0xFFFF00FF)],
          ).createShader(bounds),
          child: const Text(
            'NEURAL TRANSACTION ID',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 12),
        AnimatedBuilder(
          animation: _scanAnimation,
          builder: (context, child) => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF0F3460).withOpacity(0.8),
                  const Color(0xFF16213E).withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Color.lerp(const Color(0xFF00FF00), const Color(0xFF00FFFF), _scanAnimation.value)!,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Color.lerp(const Color(0xFF00FF00), const Color(0xFF00FFFF), _scanAnimation.value)!.withOpacity(0.3),
                  blurRadius: 15,
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.fingerprint,
                  color: Color.lerp(const Color(0xFF00FF00), const Color(0xFF00FFFF), _scanAnimation.value)!,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _generatedTransactionId,
                    style: const TextStyle(
                      color: Color(0xFF00FFFF),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00FF00), Color(0xFF80FF00)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'AUTO-GEN',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountSection() {
    return _buildCyberpunkTextField(
      controller: _amountController,
      label: 'QUANTUM AMOUNT',
      hint: 'Enter quantum credits',
      icon: Icons.currency_rupee,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      prefixText: '₹ ',
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Quantum amount required';
        }
        final amount = double.tryParse(value);
        if (amount == null || amount <= 0) {
          return 'Invalid quantum amount';
        }
        return null;
      },
    );
  }

  Widget _buildPrepaidReferenceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF00FFFF), Color(0xFFFF00FF)],
          ).createShader(bounds),
          child: const Text(
            'NEURAL PREPAID REFERENCE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 12),
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) => Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF0F3460).withOpacity(0.8),
                    const Color(0xFF16213E).withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFFF00FF),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF00FF).withOpacity(0.3),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.qr_code,
                    color: Color(0xFFFF00FF),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _prepaidReferenceController.text.isEmpty
                          ? 'Auto-generated on neural save'
                          : _prepaidReferenceController.text,
                      style: const TextStyle(
                        color: Color(0xFF00FFFF),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF00FF), Color(0xFFFF0080)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'AUTO-GEN',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultInfoSection() {
    return AnimatedBuilder(
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
            color: const Color(0xFF808080).withOpacity(0.8),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF808080).withOpacity(0.2),
              blurRadius: 15,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.security, color: Color(0xFF00FFFF)),
                const SizedBox(width: 12),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF00FFFF), Color(0xFFFF00FF)],
                  ).createShader(bounds),
                  child: const Text(
                    'NEURAL BANK CREDENTIALS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Neural Account:', '••••8287'),
            const SizedBox(height: 8),
            _buildInfoRow('Quantum Bank:', 'Neural Bank Of Maharashtra'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF808080),
            fontSize: 14,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF00FFFF),
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
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
                color: Color.lerp(const Color(0xFF00FFFF), const Color(0xFFFF00FF), _glowAnimation.value)!.withOpacity(0.6),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveTransaction,
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
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.black,
                    strokeWidth: 2,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'SYNCING TO NEURAL NETWORK...',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            )
                : const Text(
              'SAVE TO NEURAL DATABASE',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCyberpunkTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? prefixText,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF00FFFF), Color(0xFFFF00FF)],
          ).createShader(bounds),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 12),
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
                color: const Color(0xFF00FFFF).withOpacity(0.8),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00FFFF).withOpacity(0.3),
                  blurRadius: 15,
                ),
              ],
            ),
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
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
                prefixIcon: Icon(icon, color: const Color(0xFF00FFFF)),
                prefixText: prefixText,
                prefixStyle: const TextStyle(
                  color: Color(0xFF00FFFF),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
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