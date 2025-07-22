import 'package:flutter/material.dart';
import '../models/bible_reader_models.dart';

class VerseActionSheet extends StatelessWidget {
  final VerseData verse;

  const VerseActionSheet({
    super.key,
    required this.verse,
  });

  static void show(BuildContext context, VerseData verse) {
    showModalBottomSheet(
      context: context,
      builder: (context) => VerseActionSheet(verse: verse),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ayat ${verse.number}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _ActionButton(
                label: 'Highlight',
                icon: Icons.highlight,
                onTap: () {},
              ),
              _ActionButton(
                label: 'Bookmark',
                icon: Icons.bookmark,
                onTap: () {},
              ),
              _ActionButton(
                label: 'Note',
                icon: Icons.note_add,
                onTap: () {},
              ),
              _ActionButton(
                label: 'Copy',
                icon: Icons.copy,
                onTap: () {},
              ),
              _ActionButton(
                label: 'Share',
                icon: Icons.share,
                onTap: () {},
              ),
              _ActionButton(
                label: 'Image',
                icon: Icons.image,
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
