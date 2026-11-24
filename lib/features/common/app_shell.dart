import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Общая оболочка экранов с нижней навигацией.
class AppShell extends StatelessWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  static const _paths = ['/today', '/plants', '/calendar', '/catalog'];

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final selectedIndex = path.startsWith('/plants')
        ? 1
        : path.startsWith('/calendar')
            ? 2
            : path.startsWith('/catalog')
                ? 3
                : 0;

    return Scaffold(
      body: child,
      bottomNavigationBar: SafeArea(
        top: false,
        child: SizedBox(
          height: 80,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: NavigationBar(
                selectedIndex: selectedIndex,
                onDestinationSelected: (index) => context.go(_paths[index]),
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.today_outlined),
                    selectedIcon: Icon(Icons.today),
                    label: 'Сегодня',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.eco_outlined),
                    selectedIcon: Icon(Icons.eco),
                    label: 'Растения',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.calendar_month_outlined),
                    selectedIcon: Icon(Icons.calendar_month),
                    label: 'Календарь',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.local_florist_outlined),
                    selectedIcon: Icon(Icons.local_florist),
                    label: 'Каталог',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
