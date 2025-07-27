import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'payment.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({Key? key}) : super(key: key);

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> with TickerProviderStateMixin {
  MobileScannerController? controller;
  bool isScanned = false;
  bool isTorchOn = false;
  bool isInitialized = false;
  bool hasPermission = false;
  String? errorMessage;
  final ImagePicker _picker = ImagePicker();

  late AnimationController _glowController;
  late AnimationController _scanController;
  late AnimationController _pulseController;
  late Animation<double> _glowAnimation;
  late Animation<double> _scanAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeScanner();
  }

  void _setupAnimations() {
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _scanController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOut),
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowController.repeat(reverse: true);
    _scanController.repeat();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    _scanController.dispose();
    _pulseController.dispose();
    controller?.dispose();
    super.dispose();
  }

  Future<void> _initializeScanner() async {
    try {
      final cameraStatus = await Permission.camera.request();
      if (cameraStatus.isGranted) {
        controller = MobileScannerController(
          detectionSpeed: DetectionSpeed.noDuplicates,
        );
        setState(() {
          hasPermission = true;
          isInitialized = true;
        });
      } else {
        setState(() {
          hasPermission = false;
          isInitialized = true;
          errorMessage = 'Neural camera access denied';
        });
      }
    } catch (e) {
      setState(() {
        hasPermission = false;
        isInitialized = true;
        errorMessage = 'Failed to initialize neural scanner: $e';
      });
    }
  }

  void _onDetect(BarcodeCapture capture) {
    final barcode = capture.barcodes.first;
    if (!isScanned && barcode.rawValue != null) {
      setState(() {
        isScanned = true;
      });
      controller?.stop();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QrResultPage(data: barcode.rawValue!),
        ),
      );
    }
  }

  Future<void> _uploadQRFromGallery() async {
    try {
      final storageStatus = await Permission.storage.request();
      if (!storageStatus.isGranted) {
        _showPermissionDialog('Neural Storage');
        return;
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (image != null) {
        _showLoadingDialog();

        try {
          await Future.delayed(const Duration(seconds: 2));
          Navigator.pop(context);

          final simulatedQRData = "upi://pay?pa=example@upi&pn=Test%20Merchant&am=100";

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => QrResultPage(data: simulatedQRData),
            ),
          );
        } catch (e) {
          Navigator.pop(context);
          _showErrorDialog('Failed to scan neural code from image. Please try again.');
        }
      }
    } catch (e) {
      _showErrorDialog('Failed to access neural gallery. Please try again.');
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF00FFFF), width: 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00FFFF).withOpacity(0.5),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) => Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00FFFF), Color(0xFFFF00FF)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF00FFFF), Color(0xFFFF00FF)],
                  ).createShader(bounds),
                  child: const Text(
                    'SCANNING NEURAL CODE...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPermissionDialog(String permission) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF00FFFF), width: 2),
          ),
          title: ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF00FFFF), Color(0xFFFF00FF)],
            ).createShader(bounds),
            child: Text(
              '$permission Access Required',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
          content: Text(
            'Neural scanner requires $permission access to function properly. Please grant permission in system settings.',
            style: const TextStyle(
              color: Color(0xFF00FFFF),
              letterSpacing: 0.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'CANCEL',
                style: TextStyle(
                  color: Color(0xFF808080),
                  letterSpacing: 1,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00FFFF), Color(0xFFFF00FF)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
                child: const Text(
                  'SETTINGS',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFFF0040), width: 2),
          ),
          title: ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFFF0040), Color(0xFFFF4080)],
            ).createShader(bounds),
            child: const Text(
              'NEURAL ERROR',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              color: Color(0xFF00FFFF),
              letterSpacing: 0.5,
            ),
          ),
          actions: [
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF0040), Color(0xFFFF4080)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'ACKNOWLEDGE',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _toggleTorch() {
    if (controller != null && hasPermission) {
      setState(() {
        isTorchOn = !isTorchOn;
      });
      controller!.toggleTorch();
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF00FFFF), width: 2),
          ),
          title: ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF00FFFF), Color(0xFFFF00FF)],
            ).createShader(bounds),
            child: const Text(
              'NEURAL SCANNER GUIDE',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '• POINT NEURAL SCANNER AT QR CODE',
                style: TextStyle(
                  color: Color(0xFF00FFFF),
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '• ENSURE CODE IS WITHIN SCANNING FRAME',
                style: TextStyle(
                  color: Color(0xFF00FFFF),
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '• USE NEURAL TORCH FOR DARK ENVIRONMENTS',
                style: TextStyle(
                  color: Color(0xFF00FFFF),
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '• UPLOAD FROM NEURAL GALLERY IF NEEDED',
                style: TextStyle(
                  color: Color(0xFF00FFFF),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          actions: [
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00FFFF), Color(0xFFFF00FF)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'UNDERSTOOD',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPermissionDeniedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) => Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF0040), Color(0xFFFF4080)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF0040).withOpacity(0.5),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    size: 50,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF00FFFF), Color(0xFFFF00FF)],
              ).createShader(bounds),
              child: const Text(
                'NEURAL CAMERA ACCESS REQUIRED',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'To scan neural codes, please grant camera access in your device settings.',
              style: TextStyle(
                color: Color(0xFF00FFFF),
                fontSize: 16,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00FFFF), Color(0xFFFF00FF)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      openAppSettings();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    child: const Text(
                      'OPEN SETTINGS',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF808080), Color(0xFF606060)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton(
                    onPressed: _uploadQRFromGallery,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    child: const Text(
                      'UPLOAD QR',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
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

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) => Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00FFFF), Color(0xFFFF00FF)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00FFFF).withOpacity(0.5),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: const CircularProgressIndicator(
                  color: Colors.black,
                  strokeWidth: 3,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF00FFFF), Color(0xFFFF00FF)],
            ).createShader(bounds),
            child: const Text(
              'INITIALIZING NEURAL SCANNER...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          // Camera Scanner or Permission/Loading View
          if (!isInitialized)
            _buildLoadingView()
          else if (!hasPermission)
            _buildPermissionDeniedView()
          else if (controller != null)
              MobileScanner(
                controller: controller!,
                onDetect: _onDetect,
              )
            else
              const Center(
                child: Text(
                  'NEURAL SCANNER INITIALIZATION FAILED',
                  style: TextStyle(
                    color: Color(0xFFFF0040),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),

          // Header with back button, title, and help icon
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00FFFF), Color(0xFF0080FF)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00FFFF).withOpacity(0.5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                        size: 24,
                      ),
                    ),
                  ),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF00FFFF), Color(0xFFFF00FF)],
                    ).createShader(bounds),
                    child: const Text(
                      "NEURAL QR SCANNER",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _showHelpDialog,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF00FF), Color(0xFFFF0080)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF00FF).withOpacity(0.5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.help_outline,
                        color: Colors.black,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Cyberpunk Scanning Frame Overlay
          if (hasPermission && isInitialized && controller != null)
            Center(
              child: AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) => Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color.lerp(const Color(0xFF00FFFF), const Color(0xFFFF00FF), _glowAnimation.value)!,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Color.lerp(const Color(0xFF00FFFF), const Color(0xFFFF00FF), _glowAnimation.value)!.withOpacity(0.5),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Scanning line animation
                      AnimatedBuilder(
                        animation: _scanAnimation,
                        builder: (context, child) => Positioned(
                          top: 280 * _scanAnimation.value - 2,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Color.lerp(const Color(0xFF00FFFF), const Color(0xFFFF00FF), _glowAnimation.value)!,
                                  Colors.transparent,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Color.lerp(const Color(0xFF00FFFF), const Color(0xFFFF00FF), _glowAnimation.value)!,
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Corner brackets
                      ...List.generate(4, (index) {
                        final positions = [
                          {'top': 0.0, 'left': 0.0},
                          {'top': 0.0, 'right': 0.0},
                          {'bottom': 0.0, 'left': 0.0},
                          {'bottom': 0.0, 'right': 0.0},
                        ];
                        final pos = positions[index];
                        return Positioned(
                          top: pos['top'],
                          left: pos['left'],
                          right: pos['right'],
                          bottom: pos['bottom'],
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              border: Border(
                                top: pos['top'] != null ? BorderSide(
                                  color: Color.lerp(const Color(0xFF00FFFF), const Color(0xFFFF00FF), _glowAnimation.value)!,
                                  width: 4,
                                ) : BorderSide.none,
                                left: pos['left'] != null ? BorderSide(
                                  color: Color.lerp(const Color(0xFF00FFFF), const Color(0xFFFF00FF), _glowAnimation.value)!,
                                  width: 4,
                                ) : BorderSide.none,
                                right: pos['right'] != null ? BorderSide(
                                  color: Color.lerp(const Color(0xFF00FFFF), const Color(0xFFFF00FF), _glowAnimation.value)!,
                                  width: 4,
                                ) : BorderSide.none,
                                bottom: pos['bottom'] != null ? BorderSide(
                                  color: Color.lerp(const Color(0xFF00FFFF), const Color(0xFFFF00FF), _glowAnimation.value)!,
                                  width: 4,
                                ) : BorderSide.none,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),

          // Bottom Action Buttons
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Upload QR Button
                GestureDetector(
                  onTap: _uploadQRFromGallery,
                  child: Column(
                    children: [
                      AnimatedBuilder(
                        animation: _glowAnimation,
                        builder: (context, child) => Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF808080).withOpacity(_glowAnimation.value),
                                const Color(0xFF606060).withOpacity(_glowAnimation.value),
                              ],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF808080).withOpacity(_glowAnimation.value),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF808080).withOpacity(_glowAnimation.value * 0.5),
                                blurRadius: 15,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.image,
                            color: Colors.black,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "UPLOAD QR",
                        style: TextStyle(
                          color: Color(0xFF00FFFF),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                // Torch Button
                if (hasPermission && isInitialized && controller != null)
                  GestureDetector(
                    onTap: _toggleTorch,
                    child: Column(
                      children: [
                        AnimatedBuilder(
                          animation: _glowAnimation,
                          builder: (context, child) => Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isTorchOn
                                    ? [
                                  const Color(0xFFFFFF00).withOpacity(_glowAnimation.value),
                                  const Color(0xFFFF8000).withOpacity(_glowAnimation.value),
                                ]
                                    : [
                                  const Color(0xFF808080).withOpacity(_glowAnimation.value),
                                  const Color(0xFF606060).withOpacity(_glowAnimation.value),
                                ],
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isTorchOn
                                    ? const Color(0xFFFFFF00).withOpacity(_glowAnimation.value)
                                    : const Color(0xFF808080).withOpacity(_glowAnimation.value),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isTorchOn
                                      ? const Color(0xFFFFFF00).withOpacity(_glowAnimation.value * 0.8)
                                      : const Color(0xFF808080).withOpacity(_glowAnimation.value * 0.5),
                                  blurRadius: 15,
                                ),
                              ],
                            ),
                            child: Icon(
                              isTorchOn ? Icons.flash_on : Icons.flash_off,
                              color: Colors.black,
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "NEURAL TORCH",
                          style: TextStyle(
                            color: isTorchOn ? const Color(0xFFFFFF00) : const Color(0xFF00FFFF),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // BHIM | UPI Branding at bottom
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF00FFFF), Color(0xFFFF00FF)],
                ).createShader(bounds),
                child: const Text(
                  "NEURAL | UPI",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}