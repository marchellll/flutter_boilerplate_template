import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/debug/debug_screen.dart';
import '../../features/todo/presentation/pages/settings_page.dart';
import '../../features/todo/presentation/pages/todo_list_page.dart';
import '../../features/bible/presentation/pages/bible_reader_screen.dart';

class AppRouter {
  static final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const BibleReaderScreen(),
      ),
      GoRoute(
        path: '/todo',
        name: 'todo',
        builder: (context, state) => const TodoListPage(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/debug',
        name: 'debug',
        builder: (context, state) => const DebugScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found: ${state.uri}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );

  static GoRouter get router => _router;
}
