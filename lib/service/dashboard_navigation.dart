import 'package:flutter/material.dart';
import '../user_dashboard.dart';

class DashboardNavigation {
  // Add dashboard button to your existing navigation
  static Widget buildDashboardButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const UserDashboard()),
        );
      },
      icon: const Icon(Icons.dashboard),
      label: const Text('Dashboard'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
    );
  }

  // Add dashboard to bottom navigation
  static Widget buildDashboardNavItem(BuildContext context, bool isSelected) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const UserDashboard()),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Icon(
            Icons.dashboard,
            color: isSelected ? Colors.white : Colors.grey,
            size: 24,
          ),
          const SizedBox(height: 5),
          Text(
            'Dashboard',
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.white : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
