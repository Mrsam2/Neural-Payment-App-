import 'package:flutter/material.dart';
import 'package:my_app/paymentSucces.dart';


class SetUpiPinPage extends StatefulWidget {
  final String title;
  final String upiId;
  final String amount;
  final String bankName;
  final String accountNumber;

  const SetUpiPinPage({
    Key? key,
    required this.title,
    required this.upiId,
    required this.amount,
    this.bankName = 'Bank Of Maharashtra',
    this.accountNumber = '•• 8289',
  }) : super(key: key);

  @override
  _SetUpiPinPageState createState() => _SetUpiPinPageState();
}

class _SetUpiPinPageState extends State<SetUpiPinPage> {
  List<String> pinDigits = ['', '', '', ''];

  void _addDigit(String digit) {
    for (int i = 0; i < pinDigits.length; i++) {
      if (pinDigits[i].isEmpty) {
        setState(() {
          pinDigits[i] = digit;
        });
        break;
      }
    }
  }

  void _deleteDigit() {
    for (int i = pinDigits.length - 1; i >= 0; i--) {
      if (pinDigits[i].isNotEmpty) {
        setState(() {
          pinDigits[i] = '';
        });
        break;
      }
    }
  }

  void _submitPin() {
    if (pinDigits.every((d) => d.isNotEmpty)) {
      String pin = pinDigits.join();
      if (pin == '1613') {
        // Navigate to success page - keep original navigation simple
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentSuccessScreen(
              title: widget.title,
              subtitle: widget.upiId,
              amount: widget.amount,
              bankName: widget.bankName,
              accountNumber: widget.accountNumber, transactionData: {},
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Incorrect UPI PIN'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${widget.bankName}\n${widget.accountNumber}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: Colors.black,
                    ),
                  ),
                  Image.asset('assets/p6.png', width: 100),
                ],
              ),
            ),
            Divider(),

            SizedBox(height: 20),
            Text(
              'Enter 4-DIGIT UPI PIN',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),

            // PIN Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final hasDigit = pinDigits[index].isNotEmpty;
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 12),
                  width: 44,
                  height: 66,
                  child: Center(
                    child: hasDigit
                        ? Container(
                      height: 12,
                      width: 12,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                    )
                        : Container(
                      height: 2,
                      color: Colors.black,
                    ),
                  ),
                );
              }),
            ),

            SizedBox(height: 40),

            // Warning Box
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.yellow[100],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.yellow.shade800),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "UPI PIN will keep your account secure from unauthorized access. Do not share this PIN with anyone.",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 40),

            // Keypad
            Expanded(
              child: Container(
                width: double.infinity,
                color: Color(0xFFF1F3F2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildKeypadRow(['1', '2', '3']),
                    SizedBox(height: 10),
                    _buildKeypadRow(['4', '5', '6']),
                    SizedBox(height: 10),
                    _buildKeypadRow(['7', '8', '9']),
                    SizedBox(height: 10),
                    _buildKeypadRow(['⌫', '0', '✓']),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypadRow(List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits.map((digit) {
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: _buildKeypadButton(digit),
        );
      }).toList(),
    );
  }

  Widget _buildKeypadButton(String digit) {
    if (digit == '⌫') {
      return IconButton(
        onPressed: _deleteDigit,
        icon: Icon(Icons.backspace_outlined, color: Color(0xFF2A0157)),
        iconSize: 28,
      );
    } else if (digit == '✓') {
      return ElevatedButton(
        onPressed: _submitPin,
        style: ElevatedButton.styleFrom(
          shape: CircleBorder(),
          backgroundColor: Color(0xFF2A0157),
          padding: EdgeInsets.all(18),
          elevation: 0,
        ),
        child: Icon(Icons.check, color: Colors.white, size: 28),
      );
    } else {
      return TextButton(
        onPressed: () => _addDigit(digit),
        style: TextButton.styleFrom(
          backgroundColor: Colors.transparent,
          padding: EdgeInsets.all(5),
          shape: CircleBorder(),
        ),
        child: Text(
          digit,
          style: TextStyle(fontSize: 24, color: Color(0xFF2A0157)),
        ),
      );
    }
  }
}