import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavbar extends StatelessWidget {
  final Widget child;

  const BottomNavbar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    int currentIndex() {
      if (location.startsWith('/home')) return 0;
      if (location.startsWith('/chatbot')) return 1;
      if (location.startsWith('/scan')) return 2;
      if (location.startsWith('/news')) return 3;
      if (location.startsWith('/profile')) return 4;
      return 0;
    }

    return Scaffold(
      body: child,
      floatingActionButton: SizedBox(
        height: 70, // Set your desired size
        width: 70,
        child: FloatingActionButton(
          onPressed: () {
            context.go('/scan');
          },
          backgroundColor: Colors.green,
          elevation: 2,
          shape: const CircleBorder(),
          child: const Icon(Icons.qr_code, size: 30, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: SizedBox(
        height: 75,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
          child: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 10,
            color: Colors.green,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left side items
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNavItem(
                          context,
                          Icons.home,
                          'Home',
                          0,
                          currentIndex(),
                          '/home',
                        ),
                        _buildNavItem(
                          context,
                          Icons.chat,
                          'Chatbot',
                          1,
                          currentIndex(),
                          '/chatbot',
                        ),
                      ],
                    ),
                  ),

                  // Empty space for FAB
                  const SizedBox(width: 100),

                  // Right side items
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNavItem(
                          context,
                          Icons.newspaper,
                          'News',
                          3,
                          currentIndex(),
                          '/news',
                        ),
                        _buildNavItem(
                          context,
                          Icons.person,
                          'Profile',
                          4,
                          currentIndex(),
                          '/profile',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    int index,
    int currentIndex,
    String route,
  ) {
    final isSelected = currentIndex == index;
    // Khusus untuk chatbot, arahkan ke halaman tanpa navbar

    if (route == '/chatbotpreview') {
      route = '/chatbot';
    }
    if (route == '/scanpreview') {
      route = '/scan';
    }

    return IconButton(
      icon: Icon(
        icon,
        size: 30,
        color: isSelected ? Colors.white : Colors.grey[350],
      ),
      onPressed: () {
        context.go(route);
      },
    );
  }
}
