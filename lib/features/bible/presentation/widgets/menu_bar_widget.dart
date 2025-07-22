import 'package:flutter/material.dart';

class MenuBarWidget extends StatelessWidget {
  final bool isVisible;

  const MenuBarWidget({
    super.key,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _MenuButton(
            icon: Icons.home,
            label: 'Home',
            onTap: () {
              // TODO: Navigate to home/welcome screen
            },
          ),
          _MenuButton(
            icon: Icons.book,
            label: 'Bible',
            isSelected: true, // Bible reader is current screen
            onTap: () {
              // Already on Bible reader
            },
          ),
          _MenuButton(
            icon: Icons.calendar_today,
            label: 'Plans',
            onTap: () {
              // TODO: Navigate to reading plans
            },
          ),
          // Search is Phase 2
          // _MenuButton(
          //   icon: Icons.search,
          //   label: 'Search',
          //   onTap: () {
          //     // TODO: Navigate to search
          //   },
          // ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _MenuButton({
    required this.icon,
    required this.label,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isSelected ? theme.primaryColor : Colors.grey[600];

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
