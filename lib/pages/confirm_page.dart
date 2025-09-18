import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../components/search_bar.dart';
import '../components/chip_list.dart';

class ConfirmPage extends StatefulWidget {
  const ConfirmPage({super.key, required this.imageFile});

  final XFile? imageFile;

  @override
  State<ConfirmPage> createState() => _ConfirmPageState();
}

class _ConfirmPageState extends State<ConfirmPage> {
  static const String baseUrl = 'http://localhost:3001/api';
  List<String> _detectedIngredients = [];
  List<String> _allIngredients = [];
  bool _isAnalyzing = false;
  bool _hasAnalyzed = false;
  String _errorMessage = '';
  late final SearchController _searchController;
  Uint8List? _cachedImageBytes;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addIngredient(String ingredient) {
    if (ingredient.trim().isNotEmpty &&
        !_detectedIngredients.contains(ingredient.trim())) {
      setState(() {
        _detectedIngredients.add(ingredient.trim());
      });
    }
  }

  void _removeIngredient(String ingredient) {
    setState(() {
      _detectedIngredients.remove(ingredient);
    });
  }

  @override
  void initState() {
    super.initState();
    _searchController = SearchController();
    _fetchIngredients();
    // Cache image bytes for web to prevent flashing
    if (kIsWeb && widget.imageFile != null) {
      _loadImageBytes();
    }
    // Start analysis automatically when page loads
    if (widget.imageFile != null) {
      _analyzeImage();
    }
  }

  Future<void> _loadImageBytes() async {
    if (widget.imageFile != null && kIsWeb) {
      try {
        final bytes = await widget.imageFile!.readAsBytes();
        setState(() {
          _cachedImageBytes = bytes;
        });
      } catch (e) {
        debugPrint('Error loading image bytes: $e');
      }
    }
  }

  Future<void> _analyzeImage() async {
    if (widget.imageFile == null) return;

    setState(() {
      _isAnalyzing = true;
      _errorMessage = '';
      _detectedIngredients = [];
    });

    try {
      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/ai/classify'),
      );

      // Add image file
      if (kIsWeb) {
        final bytes = await widget.imageFile!.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: 'ingredient_image.jpg',
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath('file', widget.imageFile!.path),
        );
      }

      // Send request
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(responseBody);
        setState(() {
          _detectedIngredients = List<String>.from(
            jsonResponse['ingredients'] ?? [],
          );
          _hasAnalyzed = true;
          _isAnalyzing = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to analyze image. Please try again.';
          _isAnalyzing = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isAnalyzing = false;
      });
    }
  }

  Future<void> _fetchIngredients() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/meta/ingredients'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          _allIngredients = List<String>.from(jsonResponse['ingredients']);
        });
      }
    } catch (e) {
      // Handle error silently for ingredient fetching
      debugPrint('Error fetching ingredients: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          'Confirm Ingredients',
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
      body:
          widget.imageFile != null
              ? Column(
                children: [
                  // Small image preview
                  Container(
                    height: 120,
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: kIsWeb
                          ? _cachedImageBytes != null
                              ? Image.memory(
                                  _cachedImageBytes!,
                                  fit: BoxFit.cover,
                                )
                              : const Center(
                                  child: CircularProgressIndicator(),
                                )
                          : Image.file(
                              File(widget.imageFile!.path),
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),

                  // Analysis status and ingredients list
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Status section
                          Row(
                            children: [
                              Icon(
                                _isAnalyzing
                                    ? Icons.hourglass_empty
                                    : _hasAnalyzed
                                    ? Icons.check_circle
                                    : Icons.psychology,
                                color:
                                    _isAnalyzing
                                        ? Colors.grey
                                        : _hasAnalyzed
                                        ? const Color(0xFF54AF75)
                                        : Colors.grey,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isAnalyzing
                                    ? 'Analyzing ingredients...'
                                    : _hasAnalyzed
                                    ? 'Analysis Complete'
                                    : 'Ready to analyze',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      _isAnalyzing
                                          ? Colors.grey
                                          : _hasAnalyzed
                                          ? const Color(0xFF54AF75)
                                          : Colors.grey,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Ingredients section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Detected Ingredients',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Search bar for adding ingredients
                          if (_hasAnalyzed)
                            SizedBox(
                              width: double.infinity,
                              child: SearchBarWidget(
                                barHintText:
                                    'Add ingredient (e.g., tomato, onion)',
                                searchController: _searchController,
                                allSuggestions: _allIngredients,
                                onItemSelected: (item) {
                                  _addIngredient(item);
                                },
                              ),
                            ),

                          if (_hasAnalyzed) const SizedBox(height: 16),

                          // Ingredients list or loading/error state
                          Expanded(child: _buildIngredientsContent()),

                          // Action buttons
                          Container(
                            padding: const EdgeInsets.only(bottom: 24, top: 16),
                            child: Column(
                              children: [
                                if (_hasAnalyzed &&
                                    _detectedIngredients.isNotEmpty)
                                  SizedBox(
                                    width: double.infinity,
                                    height: 52,
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        // Navigate back to search with detected ingredients
                                        Navigator.pop(context, _detectedIngredients);
                                      },
                                      icon: const Icon(Icons.search),
                                      label: const Text('Find Recipes'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF54AF75,
                                        ),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                const SizedBox(height: 12),

                                // Secondary buttons
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () => Navigator.pop(context),
                                        icon: const Icon(
                                          Icons.camera_alt,
                                          size: 20,
                                        ),
                                        label: const Text('Retake Photo'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.grey.shade600,
                                          side: BorderSide(
                                            color: Colors.grey.shade400,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
              : const Center(
                child: Text(
                  'No image selected',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
    );
  }

  Widget _buildIngredientsContent() {
    if (_isAnalyzing) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF54AF75)),
            ),
            SizedBox(height: 16),
            Text(
              'AI is analyzing your image...',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: const TextStyle(fontSize: 14, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _analyzeImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF54AF75),
                foregroundColor: Colors.white,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_hasAnalyzed && _detectedIngredients.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No ingredients detected',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try taking another photo with better lighting',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_detectedIngredients.isNotEmpty) {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ChipListWidget(
            chips: _detectedIngredients,
            onChipDeleted: (chip) {
              _removeIngredient(chip);
            },
          ),
        ),
      );
    }

    return const Center(
      child: Text(
        'Ready to analyze your image',
        style: TextStyle(fontSize: 14, color: Colors.grey),
      ),
    );
  }
}
