import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:logbook_app_068/main.dart';

class VisionController extends ChangeNotifier with WidgetsBindingObserver {
  CameraController? controller;
  bool isInitialized = false;
  String? errorMessage;
  
  bool isFlashOn = false; 

  VisionController() {
    WidgetsBinding.instance.addObserver(this);
    initCamera();
  }

  Future<XFile?> takePicture() async {
  if (controller == null || !controller!.value.isInitialized) return null;
  
  try {
    final XFile file = await controller!.takePicture();
    return file;
  } catch (e) {
    debugPrint("Error saat mengambil foto: $e");
    return null;
  }
}

  Future<void> initCamera() async {
    try {
      if (cameras.isEmpty) {
        errorMessage = "No camera detected on device.";
        notifyListeners();
        return;
      }

      controller = CameraController(
        cameras[0],
        ResolutionPreset.medium, 
        enableAudio: false,      
      );

      await controller!.initialize();

      await controller!.setFlashMode(FlashMode.off);

      isFlashOn = false;
      isInitialized = true;
      errorMessage = null;
    } catch (e) {
      errorMessage = "Failed to initialize camera: $e";
    }
    notifyListeners();
  }

  Future<void> toggleFlash() async {
    if (controller == null || !controller!.value.isInitialized) return;

    try {
      if (isFlashOn) {
        await controller!.setFlashMode(FlashMode.off);
        isFlashOn = false;
      } else {
        await controller!.setFlashMode(FlashMode.torch);
        isFlashOn = true;
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Gagal menyalakan senter: $e");
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
      isInitialized = false;
      notifyListeners();
    } else if (state == AppLifecycleState.resumed) {
      initCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller?.dispose();
    super.dispose();
  }
}
