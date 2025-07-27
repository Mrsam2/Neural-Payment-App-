import 'package:flutter/material.dart';
import 'upi_name_service.dart';

class AddUpiPopup extends StatefulWidget {
  const AddUpiPopup({Key? key}) : super(key: key);

  @override
  State<AddUpiPopup> createState() => _AddUpiPopupState();
}

class _AddUpiPopupState extends State<AddUpiPopup> {
  final TextEditingController _upiIdController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _upiIdController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  bool _isValidUpiId(String upiId) {
    // Basic UPI ID validation
    return upiId.contains('@') && upiId.length > 5;
  }

  bool _isValidName(String name) {
    return name.trim().length >= 2;
  }

  Future<void> _saveUpiName() async {
    final upiId = _upiIdController.text.trim();
    final name = _nameController.text.trim();

    if (!_isValidUpiId(upiId)) {
      _showErrorSnackBar('Please enter a valid UPI ID (e.g., 9607535308@okaxis)');
      return;
    }

    if (!_isValidName(name)) {
      _showErrorSnackBar('Please enter a valid name (minimum 2 characters)');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Check if UPI ID already exists
      final exists = await UpiNameService.upiIdExists(upiId);
      
      if (exists) {
        // Show confirmation dialog for update
        final shouldUpdate = await _showUpdateConfirmationDialog(upiId, name);
        if (shouldUpdate) {
          await UpiNameService.updateUpiName(upiId: upiId, name: name);
          _showSuccessSnackBar('UPI name mapping updated successfully!');
        }
      } else {
        // Add new mapping
        await UpiNameService.addUpiName(upiId: upiId, name: name);
        _showSuccessSnackBar('UPI name mapping added successfully!');
      }

      // Clear fields and close popup
      _upiIdController.clear();
      _nameController.clear();
      Navigator.of(context).pop();

    } catch (e) {
      _showErrorSnackBar('Failed to save UPI name mapping: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _showUpdateConfirmationDialog(String upiId, String name) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            'UPI ID Already Exists',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'The UPI ID "$upiId" already exists. Do you want to update it with the new name "$name"?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Update',
                style: TextStyle(color: Colors.purple),
              ),
            ),
          ],
        );
      },
    ) ?? false;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add UPI Name',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
            
            SizedBox(height: 20),
            
            // UPI ID Field
            Text(
              'UPI ID',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _upiIdController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'e.g., 9607535308@okaxis',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.purple, width: 2),
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Name Field
            Text(
              'Name',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _nameController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'e.g., Saurabh Wankhede',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.purple, width: 2),
                ),
              ),
            ),
            
            SizedBox(height: 24),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey[600]!),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveUpiName,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Save',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
