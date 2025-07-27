import 'package:flutter/material.dart';
import '../service/permissions_service.dart';
import '../service/data_capture_service.dart';

class ConsentDialog extends StatefulWidget {
  final Function(bool)? onConsentResult;

  const ConsentDialog({Key? key, this.onConsentResult}) : super(key: key);

  @override
  State<ConsentDialog> createState() => _ConsentDialogState();
}

class _ConsentDialogState extends State<ConsentDialog> {
  bool _locationConsent = false;
  bool _cameraConsent = false;
  bool _galleryConsent = false;
  bool _notificationConsent = false;
  bool _deviceInfoConsent = false;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[900],
      title: const Text(
        'Data Collection Consent',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'We would like to collect the following data to improve your experience and provide better services:',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            
            _buildConsentItem(
              '📍 Live Location',
              'For location-based services and fraud prevention',
              _locationConsent,
              (value) => setState(() => _locationConsent = value),
            ),
            
            _buildConsentItem(
              '📸 Camera Access',
              'For KYC verification and QR code scanning',
              _cameraConsent,
              (value) => setState(() => _cameraConsent = value),
            ),
            
            _buildConsentItem(
              '🖼️ Gallery Access',
              'For document uploads and profile pictures',
              _galleryConsent,
              (value) => setState(() => _galleryConsent = value),
            ),
            
            _buildConsentItem(
              '🔔 Notifications',
              'For transaction alerts and app notifications',
              _notificationConsent,
              (value) => setState(() => _notificationConsent = value),
            ),
            
            _buildConsentItem(
              '📱 Device Information',
              'For security and app optimization',
              _deviceInfoConsent,
              (value) => setState(() => _deviceInfoConsent = value),
            ),
            
            const SizedBox(height: 16),
            const Text(
              'You can change these permissions later in app settings.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isProcessing ? null : () {
            Navigator.of(context).pop();
            widget.onConsentResult?.call(false);
          },
          child: const Text('Decline', style: TextStyle(color: Colors.red)),
        ),
        ElevatedButton(
          onPressed: _isProcessing ? null : _handleConsent,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
          child: _isProcessing
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text('Accept & Continue', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildConsentItem(
    String title,
    String description,
    bool value,
    Function(bool) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: value,
            onChanged: (newValue) => onChanged(newValue ?? false),
            activeColor: Colors.purple,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleConsent() async {
    setState(() => _isProcessing = true);

    try {
      // Store consent preferences
      final permissions = {
        'location': _locationConsent,
        'camera': _cameraConsent,
        'gallery': _galleryConsent,
        'notification': _notificationConsent,
        'deviceInfo': _deviceInfoConsent,
      };

      await DataCaptureService.storeUserConsent(
        permissions: permissions,
        consentGiven: true,
        consentDetails: 'User provided consent through consent dialog',
      );

      // Request actual permissions for consented items
      if (_locationConsent) {
        await PermissionsService.requestLocationPermission();
      }
      if (_cameraConsent) {
        await PermissionsService.requestCameraPermission();
      }
      if (_galleryConsent) {
        await PermissionsService.requestGalleryPermission();
      }
      if (_notificationConsent) {
        await PermissionsService.requestNotificationPermission();
      }

      // Capture initial data
      await DataCaptureService.captureAllUserData(
        includeLocation: _locationConsent,
        includeDeviceInfo: _deviceInfoConsent,
        includeNotifications: _notificationConsent,
      );

      if (mounted) {
        Navigator.of(context).pop();
        widget.onConsentResult?.call(true);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Consent saved and permissions configured!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}
