import 'dart:io';
import 'package:camera/camera.dart';
import 'package:farmwise_app/logic/logicGlobal.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';

class ScanAI extends StatefulWidget {
  const ScanAI({super.key});

  @override
  State<ScanAI> createState() => _ScanAIState();
}

class _ScanAIState extends State<ScanAI> {
  bool _isScanning = false;
  bool _hasResult = false;
  CameraDescription? myCamera;
  XFile? _capturedImage; // Store the captured image

  CameraController? _cameraController;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    if (cameras != null) {
      _cameraController = CameraController(
        cameras!.first,
        ResolutionPreset.medium,
      );
      _initializeControllerFuture = _cameraController!.initialize();
    }
    print('Camera is not initialized');
  }

  @override
  void dispose() {
    if (_cameraController != null) {
      _cameraController!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: Text(
          _hasResult ? 'Plant Analysis' : 'Plant Scan',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: _hasResult ? _buildAnalysisView() : _buildCameraView(),
          ),
        ],
      ),
      floatingActionButton:
          _hasResult
              ? FloatingActionButton(
                backgroundColor: Colors.white,
                child: const Icon(Icons.refresh),
                onPressed: () {
                  setState(() {
                    _hasResult = false;
                    _capturedImage = null;
                  });
                },
              )
              : null,
    );
  }

  Widget _buildCameraView() {
    if (_cameraController == null) {
      return const Text('Feature Not Available, please grant permission');
    }

    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        return Stack(
          children: [
            // Camera preview - fill the entire container
            Positioned.fill(
              child:
                  snapshot.connectionState == ConnectionState.done
                      ? CameraPreview(_cameraController!)
                      : Container(
                        color: Colors.black,
                        child: const Center(
                          child: Text(
                            'Initializing Camera',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
            ),

            // Scanning overlay and corners
            Positioned.fill(
              child: CustomPaint(painter: ScannerCornerPainter()),
            ),

            // Instruction text
            Positioned(
              top: 70,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 40),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Point the camera at the part of the plant affected by pests or disease.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),

            // Bottom controls - now positioned with bottom constraint
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Take photo button
                  GestureDetector(
                    onTap: () async {
                      setState(() {
                        _isScanning = true;
                      });

                      try {
                        await _initializeControllerFuture;
                        final image = await _cameraController!.takePicture();
                        _capturedImage = image;
                      } catch (e) {
                        print(e);
                      }

                      setState(() {
                        _isScanning = false;
                        _hasResult = true; // Show analysis view
                      });
                    },
                    child: Container(
                      height: 70,
                      width: 70,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Cancel button
            Positioned(
              bottom: 50,
              right: 50,
              child: GestureDetector(
                onTap: () {
                  context.go('/home');
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 24),
                ),
              ),
            ),

            // Gallery button
            Positioned(
              bottom: 50,
              left: 50,
              child: GestureDetector(
                onTap: () async {
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (image == null) {
                    print('Failed to open');
                    return;
                  }
                  _capturedImage = image; // Store the selected image

                  setState(() {
                    _hasResult = true; // Show analysis view
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(
                    Icons.photo_library,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),

            // Loading indicator when scanning
            if (_isScanning)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // New analysis view - displayed after taking a photo
  // Modifikasi untuk _buildAnalysisView() dan _buildOptionButton()
  Widget _buildAnalysisView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image display with rounded corners
            Container(
              width: double.infinity,
              height: 350,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              clipBehavior: Clip.hardEdge,
              child:
                  _capturedImage != null
                      ? Image.file(
                        File(_capturedImage!.path),
                        fit: BoxFit.cover,
                      )
                      : Image.asset(
                        'assets/images/potato_sample.jpg',
                        fit: BoxFit.cover,
                      ),
            ),

            const SizedBox(height: 24),

            // Option buttons
            _buildOptionButton(
              icon: Icons.eco_outlined,
              label: "Crop Information",
              onTap: () {
                // Navigasi ke halaman crop analysis dengan foto saja
                // API request akan dilakukan di halaman tujuan
                context.push(
                  '/cropanalysis',
                  extra: {
                    'imagePath': _capturedImage?.path ?? "",
                    'imageFile': _capturedImage,
                    'isLoading':
                        true, // Menandakan bahwa analisis belum dilakukan
                  },
                );
              },
            ),

            const SizedBox(height: 12),

            _buildOptionButton(
              icon: Icons.bug_report_outlined,
              label: "Investigate Pest",
              onTap: () {
                // Navigasi ke halaman pest analysis dengan foto saja
                // API request akan dilakukan di halaman tujuan
                context.push(
                  '/pestanalysis',
                  extra: {
                    'imagePath': _capturedImage?.path ?? "",
                    'imageFile': _capturedImage,
                    'isLoading':
                        true, // Menandakan bahwa analisis belum dilakukan
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.green.shade800),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade800,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade600,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for scanner corners
class ScannerCornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.green
          ..strokeWidth = 4
          ..style = PaintingStyle.stroke;

    const cornerSize = 40.0;
    final centerBox = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.8,
      height: size.width * 0.8,
    );

    // Top left corner
    canvas.drawPath(
      Path()
        ..moveTo(centerBox.left, centerBox.top + cornerSize)
        ..lineTo(centerBox.left, centerBox.top)
        ..lineTo(centerBox.left + cornerSize, centerBox.top),
      paint,
    );

    // Top right corner
    canvas.drawPath(
      Path()
        ..moveTo(centerBox.right - cornerSize, centerBox.top)
        ..lineTo(centerBox.right, centerBox.top)
        ..lineTo(centerBox.right, centerBox.top + cornerSize),
      paint,
    );

    // Bottom left corner
    canvas.drawPath(
      Path()
        ..moveTo(centerBox.left, centerBox.bottom - cornerSize)
        ..lineTo(centerBox.left, centerBox.bottom)
        ..lineTo(centerBox.left + cornerSize, centerBox.bottom),
      paint,
    );

    // Bottom right corner
    canvas.drawPath(
      Path()
        ..moveTo(centerBox.right - cornerSize, centerBox.bottom)
        ..lineTo(centerBox.right, centerBox.bottom)
        ..lineTo(centerBox.right, centerBox.bottom - cornerSize),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
