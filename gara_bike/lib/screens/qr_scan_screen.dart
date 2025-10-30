
// QR code scanner screen for starting a ride in the Gara Bike app.
// Uses mobile_scanner and custom overlay for scanning bike QR codes.
//
// Author: [Yeabsira Daniel]
// Date: [JAN/26/2025]
//
// lib/screens/qr_scan_screen.dart

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:gara_bike/providers/ride_provider.dart';
import 'package:gara_bike/screens/active_ride_screen.dart';


class QRScanScreen extends StatefulWidget {
  const QRScanScreen({super.key});

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> with SingleTickerProviderStateMixin {
  // Controller for the mobile scanner
  final MobileScannerController _scannerController = MobileScannerController();
  // Animation controller for overlay effects
  late AnimationController _animationController;
  // Whether a QR code is being processed
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Animation for overlay (if needed)
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  // Handles the detected QR code and starts the ride
  Future<void> _handleQRCode(String qrCode) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    final rideProvider = Provider.of<RideProvider>(context, listen: false);
    final response = await rideProvider.startRide(qrCode);

    if (mounted) {
      if (response['success']) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const ActiveRideScreen()),
              (route) => false,
        );
      } else {
        final error = response['error'];
        String errorMessage = 'Failed to start ride.';
        if (error is Map && error.containsKey('detail')) {
            errorMessage = error['detail'];
        } else if (error != null) {
            errorMessage = error.toString();
        }
        await _showErrorDialog(errorMessage);
        setState(() => _isProcessing = false);
      }
    }
  }

  // Shows an error dialog if ride start fails
  Future<void> _showErrorDialog(String message) {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error', style: GoogleFonts.poppins()),
        content: Text(message, style: GoogleFonts.poppins()),
        actions: <Widget>[
          TextButton(
            child: Text('Try Again', style: GoogleFonts.poppins()),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Dispose controllers
    _scannerController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Define the scan window rectangle
    final scanWindow = Rect.fromCenter(
      center: MediaQuery.of(context).size.center(const Offset(0, -50)),
      width: 250,
      height: 250,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        // Transparent app bar
        title: Text('Scan QR Code', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // QR code scanner view
          MobileScanner(
            controller: _scannerController,
            scanWindow: scanWindow,
            onDetect: (capture) {
              if (_isProcessing) return;
              final String? qrCodeValue = capture.barcodes.first.rawValue;
              if (qrCodeValue != null) {
                _handleQRCode(qrCodeValue);
              }
            },
          ),
          // Overlay with dark background and green brackets
          CustomPaint(
            painter: ScannerOverlayPainter(scanWindow: scanWindow),
          ),
          // UI controls (flash, camera switch, instructions)
          _buildScannerControls(scanWindow),
          // Loading overlay
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }


  // Builds the scanner controls and instructions overlay
  Widget _buildScannerControls(Rect scanWindow) {
    return Stack(
      children: [
        // Instruction text above the scan window
        Positioned(
          top: scanWindow.top - 40,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              'Position the QR Code within the frame',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
              ),
            ),
          ),
        ),

        // Flash and camera switch buttons at the bottom
        Positioned(
          bottom: 80,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildControlButton(
                icon: Icons.flash_on,
                onPressed: () => _scannerController.toggleTorch(),
              ),
              const SizedBox(width: 40),
              _buildControlButton(
                icon: Icons.cameraswitch,
                onPressed: () => _scannerController.switchCamera(),
              ),
            ],
          ),
        ),
      ],
    );
  }


  // Builds a circular control button for the scanner
  Widget _buildControlButton({required IconData icon, required VoidCallback onPressed}) {
    return CircleAvatar(
      radius: 30,
      backgroundColor: Colors.white.withOpacity(0.2),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 30),
        onPressed: onPressed,
      ),
    );
  }
}


// Custom painter for the scanner overlay with dark background and green brackets
class ScannerOverlayPainter extends CustomPainter {
  final Rect scanWindow;
  ScannerOverlayPainter({required this.scanWindow});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw the dark overlay with a transparent cutout for the scan window
    final backgroundPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutoutPath = Path()..addRRect(RRect.fromRectAndRadius(scanWindow, const Radius.circular(20)));
    final overlayPath = Path.combine(PathOperation.difference, backgroundPath, cutoutPath);

    final overlayPaint = Paint()..color = Colors.black.withOpacity(0.7);
    canvas.drawPath(overlayPath, overlayPaint);

    // Draw green corner brackets
    const cornerLength = 30.0;
    const strokeWidth = 5.0;
    final cornerPaint = Paint()
      ..color = Colors.green[800]!
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final cornersPath = Path()
    // Top Left
      ..moveTo(scanWindow.left, scanWindow.top + cornerLength)
      ..lineTo(scanWindow.left, scanWindow.top)
      ..lineTo(scanWindow.left + cornerLength, scanWindow.top)
    // Top Right
      ..moveTo(scanWindow.right - cornerLength, scanWindow.top)
      ..lineTo(scanWindow.right, scanWindow.top)
      ..lineTo(scanWindow.right, scanWindow.top + cornerLength)
    // Bottom Right
      ..moveTo(scanWindow.right, scanWindow.bottom - cornerLength)
      ..lineTo(scanWindow.right, scanWindow.bottom)
      ..lineTo(scanWindow.right - cornerLength, scanWindow.bottom)
    // Bottom Left
      ..moveTo(scanWindow.left + cornerLength, scanWindow.bottom)
      ..lineTo(scanWindow.left, scanWindow.bottom)
      ..lineTo(scanWindow.left, scanWindow.bottom - cornerLength);

    canvas.drawPath(cornersPath, cornerPaint);
  }

  @override
  bool shouldRepaint(ScannerOverlayPainter oldDelegate) {
    return oldDelegate.scanWindow != scanWindow;
  }
}
