import 'package:flutter/material.dart';
import '../bloc/bible_reader_state.dart';

class TopBarWidget extends StatelessWidget {
  final BibleReaderLoaded state;

  const TopBarWidget({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          
          // Version selector text button
          TextButton(
            onPressed: () => _showVersionSelector(context),
            child: Text(
              state.currentVersion.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          const Spacer(),
          
          // Current reference label
          Text(
            '${state.currentBook.nameLocal} ${state.currentChapter}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const Spacer(),
          
          // Play Audio button (if audio available) - Phase 2
          // For now, we'll show it but disable it
          IconButton(
            onPressed: null, // TODO: Implement audio functionality
            icon: const Icon(Icons.play_arrow),
          ),
          
          // Display Settings icon
          IconButton(
            onPressed: () => _showDisplaySettings(context),
            icon: const Icon(Icons.settings),
          ),
          
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  void _showVersionSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bible Versions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...state.availableVersions.map((version) => ListTile(
              title: Text(version.name),
              subtitle: Text(version.fullName),
              trailing: state.currentVersion.id == version.id
                  ? const Icon(Icons.check, color: Colors.blue)
                  : null,
              onTap: () {
                Navigator.of(context).pop();
                // TODO: Implement version change
              },
            )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showDisplaySettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Display Settings',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Font Size
            ListTile(
              leading: const Icon(Icons.text_fields),
              title: const Text('Font Size'),
              trailing: const Text('18px'), // TODO: Make dynamic
              onTap: () {
                // TODO: Implement font size adjustment
              },
            ),
            
            // Line Spacing
            ListTile(
              leading: const Icon(Icons.format_line_spacing),
              title: const Text('Line Spacing'),
              trailing: const Text('1.5x'), // TODO: Make dynamic
              onTap: () {
                // TODO: Implement line spacing adjustment
              },
            ),
            
            // Theme
            ListTile(
              leading: const Icon(Icons.palette),
              title: const Text('Theme'),
              trailing: const Text('System'), // TODO: Make dynamic
              onTap: () {
                // TODO: Implement theme selection
              },
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
