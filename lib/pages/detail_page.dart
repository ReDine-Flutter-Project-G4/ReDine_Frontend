import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

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

  List<Map<String, String>> getIngredients(Map<String, dynamic> meal) {
    final ingredients = <Map<String, String>>[];
    for (int i = 1; i <= 20; i++) {
      final ingredient = meal['strIngredient$i'];
      final measure = meal['strMeasure$i'];
      if (ingredient != null &&
          ingredient.toString().trim().isNotEmpty &&
          ingredient != '') {
        ingredients.add({
          'ingredient': ingredient.toString(),
          'measure': measure?.toString() ?? '',
        });
      }
    }
    return ingredients;
  }

  Future<void> _launchYoutube() async {
    final youtubeUrl = widget.meal['strYoutube'];
    if (youtubeUrl != null && youtubeUrl.isNotEmpty) {
      final uri = Uri.parse(youtubeUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Image.network(
                  meal['strMealThumb'],
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: CircleAvatar(
                    backgroundColor: const Color(0xFF54AF75),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              transform: Matrix4.translationValues(0.0, -250.0, 0.0),
              padding: const EdgeInsets.all(30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 15,
                    offset: Offset(0, -15),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
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
                            _buildTagChip(meal['strArea']),
                            _buildTagChip(meal['strCategory']),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  _buildSectionTitle('Ingredients'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children:
                          getIngredients(meal)
                              .map(
                                (item) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(item['ingredient'] ?? ''),
                                      ),
                                      Text(item['measure'] ?? ''),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(indent: 10, endIndent: 10),
                  _buildSectionTitle('Instructions'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(meal['strInstructions'] ?? ''),
                  ),
                  const SizedBox(height: 16),
                  const Divider(indent: 10, endIndent: 10),
                  _buildSectionTitle('Tutorial Video'),
                  TextButton.icon(
                    onPressed: _launchYoutube,
                    icon: Image.asset('assets/youtube_logo.png', scale: 8),
                    label: const Text(
                      'YouTube',
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
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
          ],
        ),
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
          color: Color(0xFF54AF75),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTagChip(String? label) {
    if (label == null || label.isEmpty) return const SizedBox.shrink();
    return Chip(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      label: Text(label, style: TextStyle(color: Colors.white, fontSize: 10)),
      backgroundColor: const Color(0xFF54AF75),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
