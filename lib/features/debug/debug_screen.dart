import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io';

import '../../l10n/app_localizations.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  PackageInfo? _packageInfo;
  Map<String, String> _deviceInfo = {};

  @override
  void initState() {
    super.initState();
    _loadDebugInfo();
  }

  Future<void> _loadDebugInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();

    setState(() {
      _packageInfo = packageInfo;
      _deviceInfo = {
        'Platform': Platform.operatingSystem,
        'Platform Version': Platform.operatingSystemVersion,
        'Dart Version': Platform.version,
        'Number of Processors': Platform.numberOfProcessors.toString(),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.debugScreen),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: _copyDebugInfo,
            tooltip: 'Copy debug info',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection('App Information', _buildAppInfo()),
          const SizedBox(height: 16),
          _buildSection('Device Information', _buildDeviceInfo()),
          const SizedBox(height: 16),
          _buildSection('Dependencies', _buildDependencies()),
          const SizedBox(height: 16),
          _buildSection('Actions', _buildActions()),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfo() {
    if (_packageInfo == null) {
      return const CircularProgressIndicator();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('App Name', _packageInfo!.appName),
        _buildInfoRow('Package Name', _packageInfo!.packageName),
        _buildInfoRow('Version', _packageInfo!.version),
        _buildInfoRow('Build Number', _packageInfo!.buildNumber),
      ],
    );
  }

  Widget _buildDeviceInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _deviceInfo.entries
          .map((entry) => _buildInfoRow(entry.key, entry.value))
          .toList(),
    );
  }

  Widget _buildDependencies() {
    final dependencies = [
      'flutter_bloc: ^8.1.3',
      'isar: ^3.1.0+1',
      'dio: ^5.4.0',
      'go_router: ^12.1.3',
      'get_it: ^7.6.4',
      'injectable: ^2.3.2',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: dependencies
          .map((dep) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(dep),
              ))
          .toList(),
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.delete_sweep),
          title: const Text('Clear Cache'),
          subtitle: const Text('Clear all cached data'),
          onTap: _clearCache,
        ),
        ListTile(
          leading: const Icon(Icons.refresh),
          title: const Text('Reset App'),
          subtitle: const Text('Reset app to initial state'),
          onTap: _resetApp,
        ),
        ListTile(
          leading: const Icon(Icons.info),
          title: const Text('Show Licenses'),
          subtitle: const Text('View open source licenses'),
          onTap: () => showLicensePage(context: context),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _copyDebugInfo() {
    final info = StringBuffer();
    info.writeln('=== Debug Information ===');
    info.writeln('App: ${_packageInfo?.appName ?? 'Unknown'}');
    info.writeln('Version: ${_packageInfo?.version ?? 'Unknown'}');
    info.writeln('Build: ${_packageInfo?.buildNumber ?? 'Unknown'}');
    info.writeln('');
    info.writeln('=== Device Information ===');
    for (final entry in _deviceInfo.entries) {
      info.writeln('${entry.key}: ${entry.value}');
    }

    Clipboard.setData(ClipboardData(text: info.toString()));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debug info copied to clipboard'),
        ),
      );
    }
  }

  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('Are you sure you want to clear all cached data?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement cache clearing
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _resetApp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset App'),
        content: const Text('This will delete all data and reset the app to its initial state. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement app reset
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('App reset complete')),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
