import 'package:flutter/material.dart';

import 'balence.dart';

class SetUpiPinPage extends StatefulWidget {
  final String bankName;
  final String accountNumber;

  SetUpiPinPage({required this.bankName, required this.accountNumber});

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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BalanceSuccessPage(
              bankName: widget.bankName,
              accountNumber: widget.accountNumber,
              balance: '0.04', // You can pass real balance here if available
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Incorrect UPI PIN')),
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
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${widget.bankName}\n${widget.accountNumber}",
                    style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17, color: Colors.black),
                  ),

                  Image.asset('assets/p6.png', width: 100), // Make sure you have this image
                ],
              ),
            ),

            Divider(),

            // Dropdown
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: 'Check Balance',
                      dropdownColor: Colors.white, // Background color of dropdown menu
                      iconEnabledColor: Colors.black, // Dropdown icon color
                      style: TextStyle(color: Colors.black, fontSize: 16), // Text style of selected item
                      items: ['Check Balance'].map((e) {
                        return DropdownMenuItem(
                          value: e,
                          child: Text(
                            e,
                            style: TextStyle(color: Colors.black), // Menu item text color
                          ),
                        );
                      }).toList(),
                      onChanged: (_) {},
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            Text(
              'Enter 4-DIGIT UPI PIN',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14,color: Colors.black),
            ),

            SizedBox(height: 10),

            // PIN Boxes
            // PIN Boxes
            // PIN Boxes
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
                      width: 32,
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



            SizedBox(height: 70),

            // Warning box
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
                      style: TextStyle(fontSize: 13,color: Colors.black,fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 70),
            SizedBox(height: 10),

            // Number Pad
            Expanded(
              child: Container(
                width: double.infinity,
                color: Color(0xFFF1F3F2), // Replace with your desired background color
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
        style: ButtonStyle(
          overlayColor: WidgetStateProperty.all(Colors.transparent),
        ),
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
          style: TextStyle(fontSize: 24, color: Color(0xFF2A0157) // Fully opaque version of #1069FF
          ),
        ),
      );
    }
  }}
