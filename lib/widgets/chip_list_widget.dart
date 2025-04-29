import 'package:flutter/material.dart';

class ChipListWidget extends StatelessWidget {
  final List<String> chips;
  final Function(String) onChipDeleted;

  const ChipListWidget({
    super.key,
    required this.chips,
    required this.onChipDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: chips.map((chip) {
        return Chip(
          label: Text(
            chip,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          backgroundColor: const Color(0xFF54AF75),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          deleteIcon: const Icon(
            Icons.close,
            color: Colors.white,
            size: 18,
          ),
          onDeleted: () => onChipDeleted(chip),
        );
      }).toList(),
    );
  }
}
