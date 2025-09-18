import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:redine_frontend/pages/confirm_page.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _openCamera() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (pickedFile != null && mounted) {
        // Navigate to confirm page and wait for result
        final result = await Navigator.push<List<String>>(
          context,
          MaterialPageRoute(
            builder: (context) => ConfirmPage(imageFile: pickedFile),
          ),
        );
        
        // If we got ingredients back, return them to the search page
        if (result != null && result.isNotEmpty && mounted) {
          Navigator.pop(context, result);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error opening camera: $e')));
      }
    }
  }

  Future<void> _openGallery() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (pickedFile != null && mounted) {
        // Navigate to confirm page and wait for result
        final result = await Navigator.push<List<String>>(
          context,
          MaterialPageRoute(
            builder: (context) => ConfirmPage(imageFile: pickedFile),
          ),
        );
        
        // If we got ingredients back, return them to the search page
        if (result != null && result.isNotEmpty && mounted) {
          Navigator.pop(context, result);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error opening gallery: $e')));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Open camera automatically when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openCamera();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          'Camera',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 24,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera_alt, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Take a photo of your ingredients',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _openCamera,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Take Photo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF54AF75),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _openGallery,
              icon: const Icon(Icons.photo_library, color: Colors.grey),
              label: const Text(
                'Choose from Gallery',
                style: TextStyle(color: Colors.grey),
              ),
              style: TextButton.styleFrom(foregroundColor: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
