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
      spacing: 6,
      runSpacing: 4,
      children:
          chips.map((chip) {
            return Chip(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              label: Text(
                chip,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
              backgroundColor: const Color(0xFF54AF75),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              deleteIcon: const Icon(
                Icons.close,
                color: Colors.white,
                size: 12,
              ),
              onDeleted: () => onChipDeleted(chip),
            );
          }).toList(),
    );
  }
}
