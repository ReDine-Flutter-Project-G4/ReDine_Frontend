import 'package:flutter/material.dart';

class AccordionItem {
  final String header;
  final String body;

  AccordionItem({required this.header, required this.body});
}

class Accordion extends StatefulWidget {
  final List<AccordionItem> items;

  const Accordion({Key? key, required this.items}) : super(key: key);

  @override
  State<Accordion> createState() => _AccordionState();
}

class _AccordionState extends State<Accordion> {
  late List<bool> _expandedStates;

  @override
  void initState() {
    super.initState();
    _expandedStates = List.generate(widget.items.length, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(widget.items.length, (index) {
        final item = widget.items[index];
        return Container(
          color: Colors.white,
          child: Column(
            children: [
              Card(
                elevation: 0,
                margin: const EdgeInsets.symmetric(vertical: 5),
                color: Colors.white,
                child: ExpansionTile(
                  title: Text(
                    item.header,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                  ),
                  onExpansionChanged: (isExpanded) {
                    setState(() {
                      _expandedStates[index] = isExpanded;
                    });
                  },
                  tilePadding: EdgeInsets.zero,
                  shape: Border.all(color: Colors.transparent),
                  collapsedIconColor: Colors.black,
                  expandedAlignment: Alignment.centerLeft,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16),
                      child: Text(
                        item.body,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(indent: 0.0, endIndent: 0.0, color: Colors.black26),
            ],
          ),
        );
      }),
    );
  }
}
