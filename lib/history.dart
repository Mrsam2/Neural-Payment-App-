import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/home_page.dart';
import 'package:my_app/search_page.dart';
import 'package:my_app/userpage.dart' hide PleaseWaitPage;
import 'Qrscan.dart';
import 'firebase_service.dart';
import 'updated_new_payment_history_page.dart';
import 'payment_success_detail.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> with TickerProviderStateMixin {
  List<Map<String, dynamic>> transactions = [];
  int _selectedIndex = 0;
  bool isLoading = true;
  String searchQuery = '';
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
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

  Future<void> _loadTransactions() async {
    try {
      setState(() {
        isLoading = true;
      });

      final userTransactions = await FirebaseService.getAllUserTransactions();

      setState(() {
        transactions = userTransactions;
        isLoading = false;
      });

      print('✅ Loaded ${transactions.length} user-specific transactions');
    } catch (e) {
      print('❌ Error loading transactions: $e');
      setState(() {
        isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading transactions: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  DateTime? _getTimestampAsDateTime(dynamic timestamp) {
    if (timestamp == null) return null;

    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is String) {
      try {
        return DateTime.parse(timestamp);
      } catch (e) {
        print('Error parsing timestamp string: $e');
        return null;
      }
    } else if (timestamp is int) {
      try {
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      } catch (e) {
        print('Error parsing timestamp int: $e');
        return null;
      }
    }

    return null;
  }

  List<Map<String, dynamic>> get filteredTransactions {
    if (searchQuery.isEmpty) return transactions;
    return transactions.where((transaction) {
      final name = (transaction['title'] ?? transaction['name'] ?? '')
          .toString()
          .toLowerCase();
      final upiId = (transaction['upiId'] ?? transaction['upi_id'] ?? '')
          .toString()
          .toLowerCase();
      return name.contains(searchQuery.toLowerCase()) ||
          upiId.contains(searchQuery.toLowerCase());
    }).toList();
  }

  Widget _buildTransactionIcon(String type) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) => Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1A1A2E),
              const Color(0xFF16213E),
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
              blurRadius: 10,
            ),
          ],
        ),
        child: type == 'mobile_recharge'
            ? Padding(
          padding: const EdgeInsets.all(12.0),
          child: Image.network(
            'https://i.postimg.cc/SxwLsVFL/f2.png',
            width: 34,
            height: 34,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.phone_android,
                color: const Color(0xFF00FFFF),
                size: 24,
              );
            },
          ),
        )
            : Icon(
          _getIconForTransactionType(type),
          color: const Color(0xFF00FFFF),
          size: 24,
        ),
      ),
    );
  }

  IconData _getIconForTransactionType(String type) {
    switch (type) {
      case 'received_from':
        return Icons.south_west;
      case 'paid_to':
        return Icons.north_east;
      case 'mobile_recharge':
        return Icons.phone_android;
      default:
        return Icons.north_east;
    }
  }

  Widget _buildProfileIcon() {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00FFFF), Color(0xFF0080FF)],
        ),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00FFFF).withOpacity(0.5),
            blurRadius: 8,
          ),
        ],
      ),
      child: const Center(
          child: Image(image: AssetImage('assets/b7.jpg'), height: 50)
      ),
    );
  }

  String _getTransactionTitle(String type) {
    switch (type) {
      case 'received_from':
        return 'NEURAL CREDIT';
      case 'paid_to':
        return 'TRANSFER';
      case 'mobile_recharge':
        return 'ENERGY BOOST';
      default:
        return 'TRANSFER';
    }
  }

  String _getStatusText(String type) {
    switch (type) {
      case 'received_from':
        return 'Synced to';
      case 'paid_to':
      case 'mobile_recharge':
        return 'Extracted from';
      default:
        return 'Extracted from';
    }
  }

  void _navigateToTransactionDetail(Map<String, dynamic> transaction) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentSuccessDetailPage(
          transaction: transaction,
          transactionDocumentId: transaction['id'] ?? '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            // Cyberpunk Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF00FFFF), Color(0xFFFF00FF)],
                    ).createShader(bounds),
                    child: const Text(
                      'DATA STREAM',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 35),
                        child: GestureDetector(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NewPaymentHistoryPage(),
                              ),
                            );
                            if (result == true) {
                              _loadTransactions();
                            }
                          },
                          child: AnimatedBuilder(
                            animation: _glowAnimation,
                            builder: (context, child) => Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF00FFFF).withOpacity(0.2),
                                    const Color(0xFFFF00FF).withOpacity(0.2),
                                  ],
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Color.lerp(
                                    const Color(0xFF00FFFF),
                                    const Color(0xFFFF00FF),
                                    _glowAnimation.value,
                                  )!,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color.lerp(
                                      const Color(0xFF00FFFF),
                                      const Color(0xFFFF00FF),
                                      _glowAnimation.value,
                                    )!.withOpacity(0.5),
                                    blurRadius: 15,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.help_outline,
                                color: Color(0xFF00FFFF),
                                size: 22,
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

            // Cyberpunk Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) => Container(
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF1A1A2E).withOpacity(0.8),
                        const Color(0xFF16213E).withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: const Color(0xFF00FFFF).withOpacity(_glowAnimation.value * 0.6),
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
                      const SizedBox(width: 20),
                      const Icon(
                        Icons.search,
                        color: Color(0xFF00FFFF),
                        size: 24,
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'SCAN NEURAL TRANSACTIONS',
                            hintStyle: TextStyle(
                              color: const Color(0xFF808080),
                              fontSize: 14,
                              letterSpacing: 1,
                            ),
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(
                            color: Color(0xFF00FFFF),
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(right: 20),
                        child: const Icon(
                          Icons.tune,
                          color: Color(0xFFFF00FF),
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Transaction List
            Expanded(
              child: isLoading
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00FFFF), Color(0xFFFF00FF)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF00FFFF), Color(0xFFFF00FF)],
                      ).createShader(bounds),
                      child: const Text(
                        'LOADING NEURAL DATA...',
                        style: TextStyle(
                          color: Colors.white,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              )
                  : filteredTransactions.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
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
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.history,
                        size: 40,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF00FFFF), Color(0xFFFF00FF)],
                      ).createShader(bounds),
                      child: const Text(
                        'NO NEURAL RECORDS FOUND',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              )
                  : RefreshIndicator(
                onRefresh: _loadTransactions,
                color: const Color(0xFF00FFFF),
                backgroundColor: const Color(0xFF1A1A2E),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: filteredTransactions.length,
                  separatorBuilder: (context, index) => Container(
                    margin: const EdgeInsets.only(left: 64),
                    child: Divider(
                      color: const Color(0xFF00FFFF).withOpacity(0.2),
                      height: 1,
                      thickness: 0.5,
                    ),
                  ),
                  itemBuilder: (context, index) {
                    final transaction = filteredTransactions[index];
                    final type = transaction['type'] ?? 'paid_to';
                    final name = transaction['title'] ?? transaction['name'] ?? 'Unknown';
                    final amount = transaction['amount']?.toString() ?? '0';
                    final timestamp = transaction['timestamp'];
                    final date = _getTimestampAsDateTime(timestamp) ?? DateTime.now();
                    final formattedDate = DateFormat('dd MMM yyyy').format(date);

                    return GestureDetector(
                      onTap: () => _navigateToTransactionDetail(transaction),
                      child: AnimatedBuilder(
                        animation: _glowAnimation,
                        builder: (context, child) => Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF1A1A2E).withOpacity(0.3),
                                const Color(0xFF16213E).withOpacity(0.3),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF00FFFF).withOpacity(_glowAnimation.value * 0.3),
                              width: 0.5,
                            ),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                _buildTransactionIcon(type),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _getTransactionTitle(type),
                                            style: const TextStyle(
                                              color: Color(0xFF808080),
                                              fontSize: 12,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                          ShaderMask(
                                            shaderCallback: (bounds) => const LinearGradient(
                                              colors: [Color(0xFF00FF00), Color(0xFF00FFFF)],
                                            ).createShader(bounds),
                                            child: Text(
                                              '₹$amount',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 19,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 1,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        name.toUpperCase(),
                                        style: const TextStyle(
                                          color: Color(0xFF00FFFF),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            formattedDate,
                                            style: const TextStyle(
                                              color: Color(0xFF808080),
                                              fontSize: 12,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                _getStatusText(type),
                                                style: const TextStyle(
                                                  color: Color(0xFF808080),
                                                  fontSize: 12,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              _buildProfileIcon(),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Cyberpunk Bottom Navigation
            _buildCyberpunkBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildCyberpunkBottomNav() {
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
              _buildCyberpunkNavItem(1, null, 'HOME', imagePath: 'assets/home.png'),
              _buildCyberpunkNavItem(0, Icons.search, 'SEARCH'),
              const SizedBox(width: 80),
              _buildCyberpunkNavItem(3, Icons.notifications_outlined, 'ALERTS'),
              _buildCyberpunkNavItem(4, Icons.access_time, 'HISTORY'),
            ],
          ),
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

  Widget _buildCyberpunkNavItem(int index, IconData? icon, String label, {String? imagePath}) {
    bool isSelected = _selectedIndex == index;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });

        if (index == 0) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => SearchPage()));
        } else if (index == 1) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
        } else if (index == 3) {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => const PleaseWaitPage(title: "Neural Alerts"),
          ));
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
            color: isSelected ? const Color(0xFF00FFFF) : const Color(0xFF808080),
          )
              : Icon(
            icon,
            color: isSelected ? const Color(0xFF00FFFF) : const Color(0xFF808080),
            size: 24,
          ),
          const SizedBox(height: 5),
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
    );
  }
}