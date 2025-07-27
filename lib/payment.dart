import 'package:flutter/material.dart';
import 'package:my_app/PINSETPAYMONEY.dart';
import 'upi_name_service.dart';

class QrResultPage extends StatefulWidget {
  final String data;

  const QrResultPage({Key? key, required this.data}) : super(key: key);

  @override
  State<QrResultPage> createState() => _QrResultPageState();
}

class _QrResultPageState extends State<QrResultPage> with TickerProviderStateMixin {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  bool isHovering = false;
  String? displayName;
  bool isLoadingName = true;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _fetchDisplayName();
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

  Future<void> _fetchDisplayName() async {
    final extractedUpiId = extractUpiId(widget.data);
    try {
      final name = await UpiNameService.getNameByUpiId(extractedUpiId);
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

  String extractUpiId(String rawData) {
    if (rawData.startsWith('upi://pay?')) {
      final uri = Uri.parse(rawData);
      final upiId = uri.queryParameters['pa'];
      return upiId ?? 'Invalid UPI ID';
    } else {
      return rawData;
    }
  }

  String maskUpiId(String upiId) {
    final localPart = upiId.split('@').first;
    if (localPart.length <= 4) return upiId;
    final last4 = localPart.substring(localPart.length - 4);
    return '*******$last4';
  }

  String getDisplayTitle(String upiId) {
    if (displayName != null && displayName!.isNotEmpty) {
      return displayName!;
    }

    final localPart = upiId.split('@').first;
    final onlyDigits = RegExp(r'^\d+$');
    if (onlyDigits.hasMatch(localPart) && localPart.length >= 8) {
      final last4 = localPart.substring(localPart.length - 4);
      return '*******$last4';
    } else {
      return localPart;
    }
  }

  bool isValidAmount() {
    final value = double.tryParse(_amountController.text);
    return value != null && value > 0;
  }

  @override
  Widget build(BuildContext context) {
    final extractedUpiId = extractUpiId(widget.data);
    final maskedUpi = maskUpiId(extractedUpiId);
    final displayTitle = getDisplayTitle(extractedUpiId);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00FFFF)),
          onPressed: () => Navigator.pop(context),
        ),
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF00FFFF), Color(0xFFFF00FF)],
          ).createShader(bounds),
          child: const Text(
            "QUANTUM PAY",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
        actions: [
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) => Container(
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFFF00FF).withOpacity(_glowAnimation.value),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF00FF).withOpacity(_glowAnimation.value * 0.5),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.help_outline, color: Color(0xFFFF00FF)),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) => Container(
              margin: const EdgeInsets.all(16),
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
                  color: const Color(0xFF00FFFF).withOpacity(_glowAnimation.value * 0.8),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00FFFF).withOpacity(_glowAnimation.value * 0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00FFFF), Color(0xFFFF00FF)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00FFFF).withOpacity(0.5),
                              blurRadius: 15,
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
                            : Center(
                          child: Text(
                            displayTitle.isNotEmpty ? displayTitle[0].toUpperCase() : '?',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: ShaderMask(
                                    shaderCallback: (bounds) => const LinearGradient(
                                      colors: [Color(0xFF00FFFF), Color(0xFFFF00FF)],
                                    ).createShader(bounds),
                                    child: Text(
                                      displayTitle.toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                                ),
                                if (displayName != null && displayName!.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF00FF00), Color(0xFF00FFFF)],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
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
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              extractedUpiId,
                              style: const TextStyle(
                                color: Color(0xFF808080),
                                fontSize: 14,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF00FFFF).withOpacity(0.1),
                          const Color(0xFFFF00FF).withOpacity(0.1),
                        ],
                      ),
                      border: Border.all(
                        color: const Color(0xFF00FFFF),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00FFFF).withOpacity(0.3),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (value) => setState(() {}),
                      style: const TextStyle(
                        color: Color(0xFF00FFFF),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        prefixIcon: const Icon(
                          Icons.currency_rupee,
                          color: Color(0xFF00FFFF),
                        ),
                        hintText: "ENTER AMOUNT",
                        hintStyle: const TextStyle(
                          color: Color(0xFF808080),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF1A1A2E).withOpacity(0.5),
                          const Color(0xFF16213E).withOpacity(0.5),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF808080),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(
                        color: Color(0xFF00FFFF),
                        letterSpacing: 0.5,
                      ),
                      decoration: InputDecoration(
                        hintText: "Add neural message (optional)",
                        hintStyle: const TextStyle(
                          color: Color(0xFF808080),
                          letterSpacing: 0.5,
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                        contentPadding: const EdgeInsets.all(16),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF00FFFF),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) => Container(
                decoration: BoxDecoration(
                  gradient: isValidAmount()
                      ? LinearGradient(
                    colors: [
                      Color.lerp(const Color(0xFF00FFFF), const Color(0xFFFF00FF), _glowAnimation.value)!,
                      Color.lerp(const Color(0xFFFF00FF), const Color(0xFF00FFFF), _glowAnimation.value)!,
                    ],
                  )
                      : const LinearGradient(
                    colors: [Color(0xFF404040), Color(0xFF606060)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isValidAmount()
                      ? [
                    BoxShadow(
                      color: Color.lerp(const Color(0xFF00FFFF), const Color(0xFFFF00FF), _glowAnimation.value)!.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ]
                      : null,
                ),
                child: ElevatedButton(
                  onPressed: isValidAmount()
                      ? () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      builder: (context) {
                        return PaymentMethodPopup(
                          amount: _amountController.text,
                          displayTitle: displayTitle,
                          extractedUpiId: extractedUpiId,
                        );
                      },
                    );
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 17),
                  ),
                  child: Text(
                    "INITIATE QUANTUM TRANSFER",
                    style: TextStyle(
                      color: isValidAmount() ? Colors.black : const Color(0xFF808080),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Fixed PaymentMethodPopup as StatefulWidget
class PaymentMethodPopup extends StatefulWidget {
  final String amount;
  final String displayTitle;
  final String extractedUpiId;

  const PaymentMethodPopup({
    Key? key,
    required this.amount,
    required this.displayTitle,
    required this.extractedUpiId,
  }) : super(key: key);

  @override
  State<PaymentMethodPopup> createState() => _PaymentMethodPopupState();
}

class _PaymentMethodPopupState extends State<PaymentMethodPopup> with TickerProviderStateMixin {
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
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) => Container(
        padding: const EdgeInsets.all(16),
        height: MediaQuery.of(context).size.height * 0.62,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF0A0A0A),
            ],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          border: Border.all(
            color: Color.lerp(const Color(0xFF00FFFF), const Color(0xFFFF00FF), _glowAnimation.value)!,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Color.lerp(const Color(0xFF00FFFF), const Color(0xFFFF00FF), _glowAnimation.value)!.withOpacity(0.4),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 19, horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF1A1A2E).withOpacity(0.8),
                    const Color(0xFF16213E).withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF00FFFF).withOpacity(_glowAnimation.value * 0.8),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00FFFF).withOpacity(_glowAnimation.value * 0.3),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF00FFFF), Color(0xFFFF00FF)],
                    ).createShader(bounds),
                    child: const Text(
                      'TOTAL QUANTUM COST',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF00FF00), Color(0xFF00FFFF)],
                    ).createShader(bounds),
                    child: Text(
                      '₹${widget.amount}',
                      style: const TextStyle(
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

            Divider(color: const Color(0xFF00FFFF).withOpacity(0.3), height: 30),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "RECOMMENDED NEURAL LINK",
                      style: TextStyle(
                        color: Color(0xFF808080),
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _bankTile("Bank Of Maharashtra", "•• 8289", "₹${widget.amount}", true),

                    const SizedBox(height: 24),
                    const Text(
                      "ADD QUANTUM METHODS",
                      style: TextStyle(
                        color: Color(0xFF808080),
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _addMethodTile("Add neural bank accounts"),
                    _addMethodTile("Add quantum credit card on UPI"),
                    _addMethodTile("Add cyber credit line on UPI"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Pay Button
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.lerp(const Color(0xFF00FFFF), const Color(0xFFFF00FF), _glowAnimation.value)!,
                      Color.lerp(const Color(0xFFFF00FF), const Color(0xFF00FFFF), _glowAnimation.value)!,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Color.lerp(const Color(0xFF00FFFF), const Color(0xFFFF00FF), _glowAnimation.value)!.withOpacity(0.6),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SetUpiPinPage(
                          title: widget.displayTitle,
                          upiId: widget.extractedUpiId,
                          amount: widget.amount,
                          bankName: 'Bank Of Maharashtra',
                          accountNumber: '•• 8289',
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    "EXECUTE TRANSFER ₹${widget.amount}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                      letterSpacing: 2,
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

  Widget _bankTile(String bank, String number, String amount, bool selected) {
    return Container(
      margin: const EdgeInsets.only(top: 6),
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
          color: selected
              ? Color.lerp(const Color(0xFF00FF00), const Color(0xFF00FFFF), _glowAnimation.value)!
              : const Color(0xFF808080),
          width: selected ? 2 : 1,
        ),
        boxShadow: selected
            ? [
          BoxShadow(
            color: Color.lerp(const Color(0xFF00FF00), const Color(0xFF00FFFF), _glowAnimation.value)!.withOpacity(0.4),
            blurRadius: 15,
          ),
        ]
            : null,
      ),
      child: Row(
        children: [
          Container(
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
                  blurRadius: 10,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset('assets/b7.jpg', height: 30, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bank.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF00FFFF),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      number,
                      style: const TextStyle(
                        color: Color(0xFF808080),
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Image.asset('assets/p6.png', height: 14),
                  ],
                ),
              ],
            ),
          ),
          if (amount.isNotEmpty)
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF00FF00), Color(0xFF00FFFF)],
              ).createShader(bounds),
              child: Text(
                amount,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          const SizedBox(width: 8),
          Icon(
            selected ? Icons.check_circle : Icons.radio_button_off,
            color: selected
                ? Color.lerp(const Color(0xFF00FF00), const Color(0xFF00FFFF), _glowAnimation.value)!
                : const Color(0xFF808080),
          ),
        ],
      ),
    );
  }

  Widget _addMethodTile(String title) {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A1A2E).withOpacity(0.6),
            const Color(0xFF16213E).withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF808080).withOpacity(_glowAnimation.value * 0.8),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.add,
            color: Color.lerp(const Color(0xFF00FFFF), const Color(0xFFFF00FF), _glowAnimation.value)!,
          ),
          const SizedBox(width: 10),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: Color.lerp(const Color(0xFF00FFFF), const Color(0xFFFF00FF), _glowAnimation.value)!,
              fontSize: 13,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}