import 'package:flutter/material.dart';

class SendMoneyPage extends StatelessWidget {
  const SendMoneyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFF1A391A),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Green header with text and icon
          Image.asset(
            'assets/p7.jpg',
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Expanded(
            child: Container(
              color: Colors.black54,
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  _optionTile(
                    icon: Icons.account_circle,
                    label: "To self bank account",
                    sub: "1 saved account",
                    onTap: () {},
                  ),
                  _optionTile(
                    icon: Icons.account_balance,
                    label: "To other's bank account",
                    sub: "using A/C number & IFSC code",
                    onTap: () {},
                  ),
                  _optionTile(
                    icon: Icons.alternate_email,
                    label: "To any UPI app",
                    sub: "using UPI ID / number",
                    onTap: () {},
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 1),
                    child: Image.asset(
                      'assets/b6.jpg', // UPI logo at the bottom
                      height: 70,
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _optionTile({
    required IconData icon,
    required String label,
    required String sub,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.deepPurple,
        child: Icon(icon, color: Colors.white),
      ),
      title: Text(label, style: TextStyle(color: Colors.white)),
      subtitle: Text(sub, style: TextStyle(color: Colors.white60, fontSize: 13)),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
      onTap: onTap,
    );
  }
}
