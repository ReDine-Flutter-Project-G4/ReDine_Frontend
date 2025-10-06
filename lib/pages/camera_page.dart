import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:redine_frontend/pages/confirm_page.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  final ImagePicker _picker = ImagePicker();

  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _cameraIndex = 0;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        _showSnack('No cameras found on this device');
        return;
      }
      await _startController(_cameras[_cameraIndex]);
    } catch (e) {
      _showSnack('Camera init error: $e');
    }
  }

  Future<void> _startController(CameraDescription description) async {
    final controller = CameraController(
      description,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    await controller.initialize();
    if (!mounted) return;
    setState(() => _controller = controller);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      c.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _startController(c.description);
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized || _isBusy) return;
    try {
      setState(() => _isBusy = true);
      final XFile file = await _controller!.takePicture();

      if (!mounted) return;
      final result = await Navigator.push<List<String>>(
        context,
        MaterialPageRoute(builder: (_) => ConfirmPage(imageFile: file)),
      );

      if (result != null && result.isNotEmpty && mounted) {
        Navigator.pop(context, result); // bubble results up
      }
    } catch (e) {
      _showSnack('Failed to take picture: $e');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _openGallery() async {
    if (_isBusy) return;
    try {
      setState(() => _isBusy = true);
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (file == null || !mounted) return;

      final result = await Navigator.push<List<String>>(
        context,
        MaterialPageRoute(builder: (_) => ConfirmPage(imageFile: file)),
      );

      if (result != null && result.isNotEmpty && mounted) {
        Navigator.pop(context, result);
      }
    } catch (e) {
      _showSnack('Error opening gallery: $e');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2 || _isBusy) return;
    _cameraIndex = (_cameraIndex + 1) % _cameras.length;
    await _controller?.dispose();
    await _startController(_cameras[_cameraIndex]);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final preview = (_controller != null && _controller!.value.isInitialized)
        ? AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: CameraPreview(_controller!),
          )
        : const Center(child: CircularProgressIndicator());

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: preview),

          // Back button
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // Bottom-left: built-in Gallery button
          Positioned(
            left: 16,
            bottom: 24,
            child: FloatingActionButton(
              heroTag: 'gallery',
              mini: true,
              backgroundColor: Colors.white.withOpacity(0.2),
              onPressed: _openGallery,
              child: const Icon(Icons.photo_library, color: Colors.white),
            ),
          ),

          // Bottom-right: switch camera
          Positioned(
            right: 16,
            bottom: 24,
            child: FloatingActionButton(
              heroTag: 'switch',
              mini: true,
              backgroundColor: Colors.white.withOpacity(0.2),
              onPressed: _switchCamera,
              child: const Icon(Icons.cameraswitch, color: Colors.white),
            ),
          ),

          // Bottom-center: shutter
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GestureDetector(
                onTap: _takePicture,
                child: Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: Center(
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isBusy ? Colors.white24 : Colors.white,
                      ),
                    ),
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
