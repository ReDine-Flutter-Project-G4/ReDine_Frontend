import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:redine_frontend/widgets/chip_tag.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:colorful_iconify_flutter/icons/logos.dart';

class DetailPage extends StatefulWidget {
  final Map<String, dynamic> meal;

  const DetailPage({super.key, required this.meal});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late YoutubePlayerController _youtubeController;

  @override
  void initState() {
    super.initState();
    final videoId = _extractYoutubeId(widget.meal['strYoutube']);
    _youtubeController = YoutubePlayerController.fromVideoId(
      videoId: videoId ?? '',
      params: const YoutubePlayerParams(showFullscreenButton: true),
      autoPlay: false,
    );
  }

  String? _extractYoutubeId(String? url) {
    if (url == null || url.isEmpty) return null;
    final uri = Uri.tryParse(url);
    return uri?.queryParameters['v'];
  }

  Future<void> _launchYoutube() async {
    final youtubeUrl = widget.meal['strYoutube'];
    if (youtubeUrl != null && youtubeUrl.isNotEmpty) {
      final uri = Uri.parse(youtubeUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the YouTube link')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final meal = widget.meal;

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.network(meal['strMealThumb'], fit: BoxFit.cover),
          ),
          CustomScrollView(
            slivers: [
              SliverAppBar(
                forceMaterialTransparency: true,
                expandedHeight: 200,
                floating: true,
                snap: true,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 15, top: 15),
                  child: CircleAvatar(
                    backgroundColor: const Color(0xFF54AF75),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(26),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            Text(
                              meal['strMeal'] ?? '',
                              style: GoogleFonts.livvic(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              alignment: WrapAlignment.center,
                              children: [
                                ChipTag(label: meal['strArea']),
                                ChipTag(label: meal['strCategory']),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSectionTitle('Ingredients'),
                      _buildIngredientList(meal),
                      const SizedBox(height: 16),
                      _buildSectionTitle('Instructions'),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          meal['strInstructions'] ?? '',
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSectionTitle('Tutorial Video'),
                      TextButton.icon(
                        onPressed: _launchYoutube,
                        icon: Iconify(Logos.youtube_icon, size: 10),
                        label: const Text(
                          'YouTube',
                          style: TextStyle(color: Colors.black, fontSize: 10),
                        ),
                      ),
                      SizedBox(
                        height: 250,
                        width: double.infinity,
                        child: YoutubePlayer(controller: _youtubeController),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Text(
        title,
        style: GoogleFonts.livvic(
          fontSize: 14,
          color: const Color(0xFF54AF75),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  List<Map<String, String>> getIngredients(Map<String, dynamic> meal) {
    final ingredients = <Map<String, String>>[];
    for (int i = 1; i <= 20; i++) {
      final ingredient = meal['strIngredient$i'];
      final measure = meal['strMeasure$i'];
      if (ingredient != null && ingredient.toString().trim().isNotEmpty) {
        ingredients.add({
          'ingredient': ingredient.toString(),
          'measure': measure?.toString() ?? '',
        });
      }
    }
    return ingredients;
  }

  Widget _buildIngredientList(Map<String, dynamic> meal) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children:
            getIngredients(meal).map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        item['ingredient'] ?? '',
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        item['measure'] ?? '',
                        style: const TextStyle(fontSize: 10),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }
}
