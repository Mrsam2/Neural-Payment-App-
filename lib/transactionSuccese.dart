// import 'package:flutter/material.dart';
//
// class TransactionSuccessScreen extends StatelessWidget {
//   const TransactionSuccessScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.green[800],
//       body: SafeArea(
//         child: Column(
//           children: [
//             // App Bar
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//               child: Row(
//                 children: [
//                   GestureDetector(
//                     onTap: () {
//                       Navigator.pop(context);
//                     },
//                     child: const Icon(Icons.arrow_back, color: Colors.white),
//                   ),
//                   const SizedBox(width: 16),
//                   const Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Transaction Successful',
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                       Text(
//                         '12:19 AM on 09 Apr 2025',
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Colors.white70,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//
//             Expanded(
//               child: Container(
//                 color: Colors.black,
//                 child: SingleChildScrollView(
//                   child: Column(
//                     children: [
//                       // Transaction Card
//                       Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: Colors.grey[900],
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           padding: const EdgeInsets.all(16.0),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const Text(
//                                 'Paid to',
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   color: Colors.white70,
//                                 ),
//                               ),
//                               const SizedBox(height: 12),
//
//                               // Recipient Info
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Row(
//                                     children: [
//                                       Container(
//                                         width: 50,
//                                         height: 50,
//                                         decoration: const BoxDecoration(
//                                           color: Colors.blue,
//                                           shape: BoxShape.circle,
//                                         ),
//                                         child: const Center(
//                                           child: Text(
//                                             'SW',
//                                             style: TextStyle(
//                                               color: Colors.white,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                       const SizedBox(width: 12),
//                                       Column(
//                                         crossAxisAlignment: CrossAxisAlignment.start,
//                                         children: [
//                                           const Text(
//                                             'Saurabh Chandanlal',
//                                             style: TextStyle(
//                                               fontSize: 16,
//                                               fontWeight: FontWeight.bold,
//                                               color: Colors.white,
//                                             ),
//                                           ),
//                                           const Text(
//                                             'Wankhede',
//                                             style: TextStyle(
//                                               fontSize: 16,
//                                               fontWeight: FontWeight.bold,
//                                               color: Colors.white,
//                                             ),
//                                           ),
//                                           Text(
//                                             'saurabhsb88214@naviaxis',
//                                             style: TextStyle(
//                                               fontSize: 14,
//                                               color: Colors.grey[400],
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                   const Text(
//                                     '₹1',
//                                     style: TextStyle(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//
//                               const SizedBox(height: 16),
//                               const Divider(color: Colors.grey),
//                               const SizedBox(height: 16),
//
//                               // Banking Details
//                               Row(
//                                 children: [
//                                   const Text(
//                                     'Banking Name',
//                                     style: TextStyle(
//                                       fontSize: 14,
//                                       color: Colors.white70,
//                                     ),
//                                   ),
//                                   const SizedBox(width: 8),
//                                   const Text(':'),
//                                   const SizedBox(width: 8),
//                                   Row(
//                                     children: [
//                                       const Text(
//                                         'Saurabh Chandanlal Wankhede',
//                                         style: TextStyle(
//                                           fontSize: 14,
//                                           color: Colors.white,
//                                         ),
//                                       ),
//                                       const SizedBox(width: 4),
//                                       Container(
//                                         padding: const EdgeInsets.all(2),
//                                         decoration: const BoxDecoration(
//                                           color: Colors.green,
//                                           shape: BoxShape.circle,
//                                         ),
//                                         child: const Icon(
//                                           Icons.check,
//                                           size: 12,
//                                           color: Colors.white,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//
//                               const SizedBox(height: 12),
//
//                               // Sent to
//                               Row(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   const Text(
//                                     'Sent to',
//                                     style: TextStyle(
//                                       fontSize: 14,
//                                       color: Colors.white70,
//                                     ),
//                                   ),
//                                   const SizedBox(width: 8),
//                                   const Text(':'),
//                                   const SizedBox(width: 8),
//                                   Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Row(
//                                         children: [
//                                           Container(
//                                             padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
//                                             decoration: BoxDecoration(
//                                               color: Colors.green[800],
//                                               borderRadius: BorderRadius.circular(4),
//                                             ),
//                                             child: const Text(
//                                               'navi',
//                                               style: TextStyle(
//                                                 fontSize: 14,
//                                                 fontWeight: FontWeight.bold,
//                                                 color: Colors.white,
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                       const SizedBox(height: 4),
//                                       Row(
//                                         children: [
//                                           const Icon(Icons.circle, size: 6, color: Colors.white70),
//                                           const SizedBox(width: 4),
//                                           Text(
//                                             'saurabhsb88214@naviaxis',
//                                             style: TextStyle(
//                                               fontSize: 14,
//                                               color: Colors.grey[400],
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//
//                               const SizedBox(height: 16),
//                               const Divider(color: Colors.grey),
//                               const SizedBox(height: 16),
//
//                               // Transfer Details
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Row(
//                                     children: [
//                                       const Icon(Icons.receipt_outlined, size: 20),
//                                       const SizedBox(width: 8),
//                                       const Text(
//                                         'Transfer Details',
//                                         style: TextStyle(
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.white,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   const Icon(Icons.keyboard_arrow_up),
//                                 ],
//                               ),
//
//                               const SizedBox(height: 16),
//
//                               // Transaction ID
//                               const Text(
//                                 'Transaction ID',
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   color: Colors.white70,
//                                 ),
//                               ),
//                               const SizedBox(height: 4),
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   const Text(
//                                     'T25040900192299004050',
//                                     style: TextStyle(
//                                       fontSize: 14,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                   const Icon(Icons.copy_outlined, size: 20),
//                                 ],
//                               ),
//
//                               const SizedBox(height: 16),
//
//                               // Debited from
//                               const Text(
//                                 'Debited from',
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   color: Colors.white70,
//                                 ),
//                               ),
//                               const SizedBox(height: 8),
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Row(
//                                     children: [
//                                       Container(
//                                         width: 40,
//                                         height: 40,
//                                         decoration: BoxDecoration(
//                                           color: Colors.white,
//                                           borderRadius: BorderRadius.circular(8),
//                                         ),
//                                         child: const Center(
//                                           child: Icon(Icons.account_balance, color: Colors.blue),
//                                         ),
//                                       ),
//                                       const SizedBox(width: 12),
//                                       const Column(
//                                         crossAxisAlignment: CrossAxisAlignment.start,
//                                         children: [
//                                           Text(
//                                             'XXXXXXXXXX0002',
//                                             style: TextStyle(
//                                               fontSize: 14,
//                                               color: Colors.white,
//                                             ),
//                                           ),
//                                           Text(
//                                             'UTR: 244763085879',
//                                             style: TextStyle(
//                                               fontSize: 14,
//                                               color: Colors.white70,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                   const Text(
//                                     '₹1',
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//
//                               const SizedBox(height: 24),
//
//                               // Action Buttons
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                                 children: [
//                                   _buildActionButton(Icons.arrow_upward, 'Send\nAgain'),
//                                   _buildActionButton(Icons.history, 'View\nHistory'),
//                                   _buildActionButton(Icons.call_split, 'Split\nExpense'),
//                                   _buildActionButton(Icons.share, 'Share\nReceipt'),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//
//                       // Support Button
//                       Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: Colors.grey[900],
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           padding: const EdgeInsets.all(16.0),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Row(
//                                 children: [
//                                   const Icon(Icons.help_outline, size: 24),
//                                   const SizedBox(width: 16),
//                                   const Text(
//                                     'Contact PhonePe Support',
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               const Icon(Icons.chevron_right, size: 24),
//                             ],
//                           ),
//                         ),
//                       ),
//
//                       // Powered by
//                       const SizedBox(height: 16),
//                       const Text(
//                         'Powered by',
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Colors.white70,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Text(
//                             'UPI',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           Container(
//                             width: 1,
//                             height: 20,
//                             color: Colors.white70,
//                           ),
//                           const SizedBox(width: 8),
//                           const Text(
//                             'ICICI Bank',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 24),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildActionButton(IconData icon, String label) {
//     return Column(
//       children: [
//         Container(
//           width: 50,
//           height: 50,
//           decoration: BoxDecoration(
//             color: Colors.purple[900],
//             shape: BoxShape.circle,
//           ),
//           child: Icon(icon, color: Colors.white),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           label,
//           textAlign: TextAlign.center,
//           style: const TextStyle(
//             fontSize: 12,
//             color: Colors.white,
//           ),
//         ),
//       ],
//     );
//   }
// }