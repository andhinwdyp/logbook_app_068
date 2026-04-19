import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'preview_pcd_page.dart';
import 'vision_controller.dart';
import 'damage_painter.dart';
import 'dart:async';
import 'dart:math';

class VisionView extends StatefulWidget {
  const VisionView({super.key});

  @override
  State<VisionView> createState() => _VisionViewState();
}

class _VisionViewState extends State<VisionView> {
  late VisionController _visionController;

  Timer? _mockTimer;
  double _mockX = 0.5;
  double _mockY = 0.5;

  @override
  void initState() {
    super.initState();
    _visionController = VisionController();
    _startMockDetection();
  }

  void _startMockDetection() {
    _mockTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _mockX = Random().nextDouble();
          _mockY = Random().nextDouble();
        });
      }
    });
  }

  @override
  void dispose() {
    _mockTimer?.cancel();
    _visionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Smart Patrol Vision")),
      body: ListenableBuilder(
        listenable: _visionController,
        builder: (context, child) {
          if (!_visionController.isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }
          return _buildVisionStack();
        },
      ),
    );
  }

  Widget _buildVisionStack() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // LAYER 1: Hardware Preview
        Positioned.fill(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: 100,
              child: AspectRatio(
                aspectRatio: 1 / _visionController.controller!.value.aspectRatio,
                child: CameraPreview(_visionController.controller!),
              ),
            ),
          ),
        ),

        // LAYER 2: Digital Overlay
        Positioned.fill(
          child: CustomPaint(
            painter: DamagePainter(normX: _mockX, normY: _mockY), 
          ),
        ),

        // LAYER 3: Tombol Flash
        Positioned(
          bottom: 60,
          right: 50,
          child: FloatingActionButton(
            shape: const CircleBorder(),
            backgroundColor: _visionController.isFlashOn ? Colors.orangeAccent : Colors.grey.shade800,
            onPressed: () {
              _visionController.toggleFlash();
            },
            child: Icon(
              _visionController.isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
            ),
          ),
        ),

        // LAYER 4: Tombol Shutter
        Positioned(
          bottom: 50,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: () async {
                final file = await _visionController.controller?.takePicture();
                
                if (_visionController.isFlashOn) {
                  await _visionController.toggleFlash();
                }

                if (file != null && mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PreviewPCDPage(imagePath: file.path),
                    ),
                  );
                }
              },

              child: Container(
                width: 75,
                height: 75,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300, width: 6), 
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}