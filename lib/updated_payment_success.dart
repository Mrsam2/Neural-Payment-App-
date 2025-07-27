// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'firebase_service.dart';
// import 'payment_success_detail.dart';
//
// class PaymentSuccessScreen extends StatefulWidget {
//   final String title;
//   final String subtitle;
//   final String amount;
//   final String bankName;
//   final String accountNumber;
//
//   const PaymentSuccessScreen({
//     super.key,
//     required this.title,
//     required this.amount,
//     required this.bankName,
//     required this.subtitle,
//     required this.accountNumber, String? recipientPhoneNumber, required String senderName,
//   });
//
//   @override
//   State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
// }
//
// class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
//   String? transactionDocumentId;
//   bool isStoringTransaction = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _storeTransactionInFirebase();
//   }
//
//   Future<void> _storeTransactionInFirebase() async {
//     try {
//       final documentId = await FirebaseService.storePaymentTransaction(
//         title: widget.title,
//         upiId: widget.subtitle,
//         amount: widget.amount,
//         bankName: widget.bankName,
//         accountNumber: widget.accountNumber,
//       );
//
//       setState(() {
//         transactionDocumentId = documentId;
//         isStoringTransaction = false;
//       });
//     } catch (e) {
//       setState(() {
//         isStoringTransaction = false;
//       });
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to store transaction: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
//
//   void _navigateToTransactionDetails() {
//     if (transactionDocumentId != null) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => PaymentSuccessDetailPage(
//             transactionDocumentId: transactionDocumentId!, transaction: {},
//           ),
//         ),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Transaction details not available yet'),
//           backgroundColor: Colors.orange,
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // Current date and time - dynamically generated
//     final now = DateTime.now();
//     final formattedDate = DateFormat('dd MMM yyyy at hh:mm a').format(now);
//
//     return Scaffold(
//       body: Stack(
//         children: [
//           Column(
//             children: [
//               Container(height: 475, color: Colors.green.shade700),
//               Expanded(child: Container(color: Colors.black45)),
//             ],
//           ),
//           SafeArea(
//             child: Column(
//               children: [
//                 const SizedBox(height: 10),
//                 Expanded(
//                   child: SingleChildScrollView(
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 20.0),
//                       child: Column(
//                         children: [
//                           const SizedBox(height: 20),
//                           Container(
//                             width: 120,
//                             height: 120,
//                             child: Center(
//                               child: Image.asset('assets/done1.gif'),
//                             ),
//                           ),
//                           const Text(
//                             'Payment Successful',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 24,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           const SizedBox(height: 5),
//                           // Dynamic current date and time
//                           Text(
//                             formattedDate,
//                             style: TextStyle(
//                               color: Colors.white.withOpacity(0.9),
//                               fontSize: 16,
//                             ),
//                           ),
//                           const SizedBox(height: 30),
//                           Container(
//                             width: double.infinity,
//                             decoration: BoxDecoration(
//                               color: Colors.grey.shade900,
//                               borderRadius: BorderRadius.circular(16),
//                             ),
//                             child: Column(
//                               children: [
//                                 Padding(
//                                   padding: const EdgeInsets.all(20.0),
//                                   child: Row(
//                                     children: [
//                                       Container(
//                                         width: 60,
//                                         height: 60,
//                                         decoration: const BoxDecoration(
//                                           color: Color(0xFF9370DB),
//                                           borderRadius: BorderRadius.all(Radius.circular(16)),
//                                         ),
//                                         child: const Icon(
//                                           Icons.person_outline,
//                                           color: Colors.white,
//                                           size: 30,
//                                         ),
//                                       ),
//                                       const SizedBox(width: 15),
//                                       Expanded(
//                                         child: Column(
//                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                           children: [
//                                             // Dynamic title from payment page
//                                             Text(
//                                               widget.title,
//                                               style: TextStyle(
//                                                 color: Colors.white,
//                                                 fontSize: 18,
//                                                 fontWeight: FontWeight.bold,
//                                               ),
//                                             ),
//                                             SizedBox(height: 4),
//                                             // Dynamic UPI ID/phone number
//                                             Text(
//                                               widget.subtitle,
//                                               style: TextStyle(
//                                                 color: Colors.white70,
//                                                 fontSize: 14,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.symmetric(horizontal: 20.0),
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       // Dynamic amount from payment page
//                                       Text(
//                                         '₹${widget.amount}',
//                                         style: TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 28,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                       const Text(
//                                         'Split Expense',
//                                         style: TextStyle(
//                                           color: Color(0xFF9370DB),
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 const SizedBox(height: 20),
//                                 const Divider(height: 1, color: Colors.grey),
//                                 IntrinsicHeight(
//                                   child: Row(
//                                     children: [
//                                       Expanded(
//                                         child: TextButton.icon(
//                                           onPressed: _navigateToTransactionDetails,
//                                           icon: Container(
//                                             width: 40,
//                                             height: 40,
//                                             decoration: const BoxDecoration(
//                                               color: Color(0xFF9370DB),
//                                               shape: BoxShape.circle,
//                                             ),
//                                             child: isStoringTransaction
//                                                 ? SizedBox(
//                                                     width: 20,
//                                                     height: 20,
//                                                     child: CircularProgressIndicator(
//                                                       color: Colors.white,
//                                                       strokeWidth: 2,
//                                                     ),
//                                                   )
//                                                 : const Icon(
//                                                     Icons.receipt_outlined,
//                                                     color: Colors.white,
//                                                     size: 20,
//                                                   ),
//                                           ),
//                                           label: const Text(
//                                             'View Details',
//                                             style: TextStyle(
//                                               color: Colors.white,
//                                               fontSize: 16,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                       const VerticalDivider(width: 1, color: Colors.grey),
//                                       Expanded(
//                                         child: TextButton.icon(
//                                           onPressed: () {
//                                             // Implement share functionality
//                                             ScaffoldMessenger.of(context).showSnackBar(
//                                               SnackBar(
//                                                 content: Text('Share functionality coming soon!'),
//                                                 backgroundColor: Colors.orange,
//                                               ),
//                                             );
//                                           },
//                                           icon: Container(
//                                             width: 40,
//                                             height: 40,
//                                             decoration: const BoxDecoration(
//                                               color: Color(0xFF9370DB),
//                                               shape: BoxShape.circle,
//                                             ),
//                                             child: const Icon(
//                                               Icons.share,
//                                               color: Colors.white,
//                                               size: 20,
//                                             ),
//                                           ),
//                                           label: const Text(
//                                             'Share Receipt',
//                                             style: TextStyle(
//                                               color: Colors.white,
//                                               fontSize: 16,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const SizedBox(height: 20),
//                           const ImageSliderBanner(),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 GestureDetector(
//                   onTap: () {
//                     Navigator.popUntil(context, (route) => route.isFirst);
//                   },
//                   child: Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//                     color: Colors.black,
//                     child: const Text(
//                       'Done',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         color: Color(0xFF9370DB),
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class ImageSliderBanner extends StatefulWidget {
//   const ImageSliderBanner({super.key});
//
//   @override
//   _ImageSliderBannerState createState() => _ImageSliderBannerState();
// }
//
// class _ImageSliderBannerState extends State<ImageSliderBanner> {
//   final PageController _controller = PageController();
//   int _currentPage = 0;
//
//   final List<String> _imagePaths = [
//     'assets/b4.jpg',
//     'assets/b5.jpg',
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     Timer.periodic(Duration(seconds: 5), (timer) {
//       if (_currentPage < _imagePaths.length - 1) {
//         _currentPage++;
//       } else {
//         _currentPage = 0;
//       }
//       _controller.animateToPage(
//         _currentPage,
//         duration: Duration(milliseconds: 500),
//         curve: Curves.easeInOut,
//       );
//     });
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Container(
//           height: 300,
//           margin: EdgeInsets.symmetric(horizontal: 0),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(5),
//             child: PageView.builder(
//               controller: _controller,
//               itemCount: _imagePaths.length,
//               itemBuilder: (context, index) {
//                 return Image.asset(
//                   _imagePaths[index],
//                   fit: BoxFit.cover,
//                   width: double.infinity,
//                 );
//               },
//               onPageChanged: (index) {
//                 setState(() {
//                   _currentPage = index;
//                 });
//               },
//             ),
//           ),
//         ),
//         SizedBox(height: 8),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: List.generate(_imagePaths.length, (index) {
//             return AnimatedContainer(
//               duration: Duration(milliseconds: 300),
//               margin: EdgeInsets.symmetric(horizontal: 0),
//               height: 6,
//               width: _currentPage == index ? 20 : 6,
//               decoration: BoxDecoration(
//                 color: _currentPage == index ? Colors.white : Colors.grey,
//                 borderRadius: BorderRadius.circular(3),
//               ),
//             );
//           }),
//         ),
//       ],
//     );
//   }
// }