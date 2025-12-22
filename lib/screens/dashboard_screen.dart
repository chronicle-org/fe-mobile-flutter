import 'package:flutter/material.dart';
import 'package:chronicle/models/auth_response.dart';
import 'package:chronicle/screens/home_screen.dart';
import 'package:chronicle/screens/profile_screen.dart';
import 'package:chronicle/screens/search_screen.dart';
import 'package:chronicle/screens/edit_post_screen.dart';
import 'package:chronicle/services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.onThemeToggle,
    required this.loginData,
    required this.onLogout,
  });

  final VoidCallback onThemeToggle;
  final LoginResponse loginData;
  final VoidCallback onLogout;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int currentPageIndex = 0;

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await ApiService.logout();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 1),
          content: Text('Logged out successfully.'),
          backgroundColor: Colors.green,
        ),
      );
      widget.onLogout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Determine which widget to show based on navigation index
    Widget content;
    bool showAppBar = true;
    String title = 'Home';

    switch (currentPageIndex) {
      case 0:
        content = const HomeScreen(
          searchQuery: '',
        ); // No search query passed from parent
        title = 'Home';
        break;
      case 1:
        content = const SearchScreen();
        showAppBar = false; // SearchScreen has its own AppBar with search field
        break;
      case 2:
        content = ProfileScreen(userId: widget.loginData.id);
        showAppBar = false; // Profile has its own SliverAppBar
        break;
      case 3:
        content = const Center(child: Text('Notifications (Coming Soon)'));
        title = 'Notifications';
        break;
      default:
        content = const Center(child: Text('Error'));
    }

    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: Text(title),
              actions: [
                IconButton(
                  icon: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
                  onPressed: widget.onThemeToggle,
                  tooltip: isDark ? 'Dark Theme' : 'Light Theme',
                ),
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: _handleLogout,
                  tooltip: 'Logout',
                ),
              ],
            )
          : null,
      body: content,
      floatingActionButton: currentPageIndex == 0 || currentPageIndex == 2
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditPostScreen(),
                  ),
                );
              },
              child: const Icon(Icons.edit),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Theme.of(
          context,
        ).colorScheme.primary.withValues(alpha: 0.2),
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
