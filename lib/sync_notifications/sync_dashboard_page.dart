// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:my_app/sync_notifications/sync_firebase_service.dart';
// import 'package:my_app/sync_notifications/sync_login_page.dart';
//
// class SyncDashboardPage extends StatefulWidget {
//   const SyncDashboardPage({super.key});
//
//   @override
//   State<SyncDashboardPage> createState() => _SyncDashboardPageState();
// }
//
// class _SyncDashboardPageState extends State<SyncDashboardPage> {
//   final SyncFirebaseService _firebaseService = SyncFirebaseService();
//   final TextEditingController _deviceNameController = TextEditingController();
//   final String _currentDeviceId = 'your_device_id_here'; // Replace with actual device ID
//
//   @override
//   void initState() {
//     super.initState();
//     // Ensure user is logged in, otherwise redirect
//     if (_firebaseService.getCurrentUser() == null) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const SyncLoginPage()),
//         );
//       });
//     }
//   }
//
//   Future<void> _addDevice() async {
//     final user = _firebaseService.getCurrentUser();
//     if (user == null || _deviceNameController.text.isEmpty) return;
//
//     // try {
//       await _firebaseService.addDevice(
//         user.uid,
//         _deviceNameController.text.trim(),
//         _currentDeviceId, // In a real app, this would be a unique device ID
//       );
//       _deviceNameController.clear();
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Device added successfully!'), backgroundColor: Colors.green),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to add device: $e'), backgroundColor: Colors.red),
//       );
//     }
//   }
//
//   Future<void> _deleteDevice(String deviceId) async {
//     final user = _firebaseService.getCurrentUser();
//     if (user == null) return;
//
//     try {
//       await _firebaseService.deleteDevice(user.uid, deviceId);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Device deleted successfully!'), backgroundColor: Colors.green),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to delete device: $e'), backgroundColor: Colors.red),
//       );
//     }
//   }
//
//   Future<void> _logout() async {
//     await _firebaseService.signOut();
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => const SyncLoginPage()),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final user = _firebaseService.getCurrentUser();
//
//     if (user == null) {
//       // Should not happen due to initState check, but as a fallback
//       return const Scaffold(
//         backgroundColor: Colors.black,
//         body: Center(
//           child: CircularProgressIndicator(color: Colors.purple),
//         ),
//       );
//     }
//
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         title: const Text(
//           'Sync Notifications Dashboard',
//           style: TextStyle(color: Colors.white),
//         ),
//         iconTheme: const IconThemeData(color: Colors.white),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout, color: Colors.white),
//             onPressed: _logout,
//             tooltip: 'Logout',
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Welcome, ${user.email ?? 'User'}!',
//               style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               'Your Devices:',
//               style: TextStyle(color: Colors.white70, fontSize: 16),
//             ),
//             const SizedBox(height: 10),
//             Expanded(
//               child: StreamBuilder<QuerySnapshot>(
//                 stream: _firebaseService.getDevices(user.uid),
//                 builder: (context, snapshot) {
//                   if (snapshot.hasError) {
//                     return Center(
//                       child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
//                     );
//                   }
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const Center(
//                       child: CircularProgressIndicator(color: Colors.purple),
//                     );
//                   }
//                   if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                     return const Center(
//                       child: Text('No devices added yet.', style: TextStyle(color: Colors.grey)),
//                     );
//                   }
//
//                   final devices = snapshot.data!.docs;
//                   return ListView.builder(
//                     itemCount: devices.length,
//                     itemBuilder: (context, index) {
//                       final device = devices[index];
//                       final deviceName = device['name'] ?? 'Unknown Device';
//                       final deviceId = device['deviceId'] ?? 'N/A';
//                       return Card(
//                         color: Colors.grey[900],
//                         margin: const EdgeInsets.symmetric(vertical: 8),
//                         child: ListTile(
//                           leading: const Icon(Icons.devices_other, color: Colors.purple),
//                           title: Text(deviceName, style: const TextStyle(color: Colors.white)),
//                           subtitle: Text('ID: $deviceId', style: TextStyle(color: Colors.grey[400])),
//                           trailing: IconButton(
//                             icon: const Icon(Icons.delete, color: Colors.redAccent),
//                             onPressed: () => _deleteDevice(device.id),
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//             const SizedBox(height: 20),
//             TextField(
//               controller: _deviceNameController,
//               style: const TextStyle(color: Colors.white),
//               decoration: InputDecoration(
//                 labelText: 'Add New Device Name',
//                 labelStyle: TextStyle(color: Colors.grey[400]),
//                 filled: true,
//                 fillColor: Colors.grey[900],
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide.none,
//                 ),
//                 suffixIcon: IconButton(
//                   icon: const Icon(Icons.add, color: Colors.purple),
//                   onPressed: _addDevice,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             Center(
//               child: Text(
//                 'Current Device ID: $_currentDeviceId',
//                 style: TextStyle(color: Colors.grey[600], fontSize: 12),
//               ),
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               'Note: For full notification sync features, additional native Android setup is required.',
//               style: TextStyle(color: Colors.orange, fontSize: 12),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
