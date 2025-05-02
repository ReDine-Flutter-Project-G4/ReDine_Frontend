import 'package:flutter/material.dart';
import '../widgets/accordion.dart';

class HelpTabPage extends StatefulWidget {
  const HelpTabPage({super.key});

  @override
  State<HelpTabPage> createState() => _HelpTabPageState();
}

class _HelpTabPageState extends State<HelpTabPage> {
  final List<AccordionItem> _items = [
    AccordionItem(
      header: 'How to use ReDine',
      body: '''New to ReDine? Don’t worry — getting started is easy! 
Our app is designed to help you discover delicious recipes based on what you already have in your kitchen. Just follow these simple steps:
1. Add the ingredients you have.
2. Set your preferences — including any food you want to avoid, preferred food categories, and cuisines you’d like to eat.
3. Let ReDine find recipes that match.
4. Browse the suggested menus, pick one you like, and follow the step-by-step instructions to cook.''',
    ),
    AccordionItem(
      header: 'How are recipes ranked',
      body:
          "Recipes are ranked by how closely they match what you already have. The more ingredients from your fridge a recipe uses and the fewer it’s missing the higher it appears. We also take your dietary preferences into account, so you see the most relevant and useful options first.",
    ),
    AccordionItem(
      header: 'What if I don’t have exact quantities?',
      body:
          "No worries! ReDine recipes are flexible. You can adjust ingredient amounts to suit your taste or what's available — just be mindful of strong flavors like spices and sauces. The app is designed to help you make the most of what you have.",
    ),
    AccordionItem(
      header: 'What if I don’t have all the ingredients?',
      body:
          "That’s okay! ReDine will still suggest recipes based on your available ingredients. If you're missing something, the app may offer substitute suggestions or highlight recipes where those ingredients are optional. You can also use your creativity to swap similar items.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView(
        children: [
          const SizedBox(height: 50),
          const Center(
            child: Text(
              'Help Center',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Frequently Asked Questions (FAQs)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF54AF75),
            ),
          ),
          Accordion(items: _items),
          const SizedBox(height: 30),
          const Text(
            "Contact Support Section",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF54AF75),
            ),
          ),
          const SizedBox(height: 10),
          const Text("King Mongkut’s University of Technology Thonburi 126 Pracha Uthit Rd, Bang Mot, Thung Khru, Bangkok 10140"),
          const SizedBox(height: 20),
          const Text("Phone: +66 9999 9999"),
          const Text("Email: redine.co@gmail.com"),
        ],
      ),
    );
  }
}
