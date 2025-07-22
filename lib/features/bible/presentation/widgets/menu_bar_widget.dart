import 'package:flutter/material.dart';

class MenuBarWidget extends StatelessWidget {
  final VoidCallback onMoreTap;

  const MenuBarWidget({
    super.key,
    required this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: Colors.grey[600]!,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _MenuButton(
            icon: Icons.home,
            label: 'Home',
            onTap: () {},
            isActive: false,
          ),
          _MenuButton(
            icon: Icons.book,
            label: 'Bible',
            onTap: () {},
            isActive: true,
          ), // Active item
          _MenuButton(
            icon: Icons.calendar_today,
            label: 'Plans',
            onTap: () {},
            isActive: false,
          ),
          _MenuButton(
            icon: Icons.more_horiz,
            label: 'More',
            onTap: onMoreTap,
            isActive: false,
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color: isActive ? Colors.white : Colors.grey[600],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? Colors.white : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
