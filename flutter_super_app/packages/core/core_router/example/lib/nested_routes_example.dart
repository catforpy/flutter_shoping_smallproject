import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Three-level nested routes example
///
/// Level structure:
/// Level 1: Left navigation bar (fixed) - Shell Route
/// Level 2: Right content area with horizontal tabs - Shell Route
/// Level 3: Content pages (Latest/Hot lists)
///
/// Route hierarchy:
/// / (root shell with left nav)
/// ├── /home (home with top tabs)
/// │   ├── /home/latest
/// │   └── /home/hot
/// ├── /video
/// ├── /message
/// └── /profile
class NestedRoutesExample extends StatefulWidget {
  const NestedRoutesExample({super.key});

  @override
  State<NestedRoutesExample> createState() => _NestedRoutesExampleState();
}

class _NestedRoutesExampleState extends State<NestedRoutesExample> {
  late GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = _createRouter();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Nested Routes Example',
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }

  GoRouter _createRouter() {
    return GoRouter(
      initialLocation: '/home/latest',
      debugLogDiagnostics: true,
      routes: [
        // Level 1 & 2: Root shell with left nav AND home tabs combined
        // Using a StatefulShellBranch for each main section
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return Scaffold(
              body: Row(
                children: [
                  // Left navigation (fixed)
                  SizedBox(
                    width: 120,
                    child: Container(
                      color: Colors.grey[100],
                      child: _buildLeftNav(
                        navigationShell: navigationShell,
                      ),
                    ),
                  ),
                  // Right content (child routes)
                  Expanded(child: navigationShell),
                ],
              ),
            );
          },
          branches: [
            // Home branch with nested tabs
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/home',
                  pageBuilder: (context, state) => const NoTransitionPage(
                    child: HomeWithTabs(),
                  ),
                  routes: [
                    GoRoute(
                      path: 'latest',
                      pageBuilder: (context, state) => const NoTransitionPage(
                        child: ContentPage(title: 'Latest', count: 20),
                      ),
                    ),
                    GoRoute(
                      path: 'hot',
                      pageBuilder: (context, state) => const NoTransitionPage(
                        child: ContentPage(title: 'Hot', count: 20),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Video branch
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/video',
                  pageBuilder: (context, state) => const NoTransitionPage(
                    child: PlaceholderPage('Video Page'),
                  ),
                ),
              ],
            ),
            // Message branch
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/message',
                  pageBuilder: (context, state) => const NoTransitionPage(
                    child: PlaceholderPage('Message Page'),
                  ),
                ),
              ],
            ),
            // Profile branch
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/profile',
                  pageBuilder: (context, state) => const NoTransitionPage(
                    child: PlaceholderPage('Profile Page'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Route error: ${state.uri}'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeftNav({
    required StatefulNavigationShell navigationShell,
  }) {
    return Column(
      children: [
        _buildNavItem(
          label: 'Home',
          index: 0,
          navigationShell: navigationShell,
          icon: Icons.home,
        ),
        _buildNavItem(
          label: 'Video',
          index: 1,
          navigationShell: navigationShell,
          icon: Icons.video_library,
        ),
        _buildNavItem(
          label: 'Message',
          index: 2,
          navigationShell: navigationShell,
          icon: Icons.message,
        ),
        _buildNavItem(
          label: 'Profile',
          index: 3,
          navigationShell: navigationShell,
          icon: Icons.person,
        ),
      ],
    );
  }

  Widget _buildNavItem({
    required String label,
    required int index,
    required StatefulNavigationShell navigationShell,
    required IconData icon,
  }) {
    final isSelected = navigationShell.currentIndex == index;
    return ListTile(
      leading: Icon(icon, size: 20),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.blue : Colors.black87,
        ),
      ),
      selected: isSelected,
      selectedTileColor: Colors.blue[50],
      onTap: () => navigationShell.goBranch(index),
    );
  }
}

/// Home page with horizontal tabs
/// This is Level 2 of the nested routing
class HomeWithTabs extends StatefulWidget {
  const HomeWithTabs({super.key});

  @override
  State<HomeWithTabs> createState() => _HomeWithTabsState();
}

class _HomeWithTabsState extends State<HomeWithTabs> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Horizontal tabs
          _buildHorizontalTabs(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
              if (index == 0) {
                context.go('/home/latest');
              } else if (index == 1) {
                context.go('/home/hot');
              }
            },
            tabs: ['Latest', 'Hot'],
          ),
          // Content area - child routes render here
          const Expanded(
            child: _ChildRouteOutlet(),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalTabs({
    required int currentIndex,
    required Function(int) onTap,
    required List<String> tabs,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          return Expanded(
            child: InkWell(
              onTap: () => onTap(index),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: currentIndex == index ? Colors.blue : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  tabs[index],
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: currentIndex == index ? FontWeight.bold : FontWeight.normal,
                    color: currentIndex == index ? Colors.blue : Colors.grey[700],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Content page with list items
/// This is Level 3 of the nested routing
class ContentPage extends StatelessWidget {
  final String title;
  final int count;

  const ContentPage({super.key, required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: count,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text('$title Item $index'),
            subtitle: const Text('Tap to view details'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Tapped: $title Item $index'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// Placeholder page for other sections
class PlaceholderPage extends StatelessWidget {
  final String title;

  const PlaceholderPage(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: Colors.green.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Navigate using left menu',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

/// Child route outlet widget
/// In GoRouter, child routes render automatically in the widget tree
class _ChildRouteOutlet extends StatelessWidget {
  const _ChildRouteOutlet();

  @override
  Widget build(BuildContext context) {
    // This is a placeholder - actual content comes from nested routes
    // GoRouter handles rendering child routes automatically
    return const SizedBox.shrink();
  }
}
