import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int selectedIndex = 0;

  void changePage(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C1425),
      body: IndexedStack(
        index: selectedIndex,
        children: [
          HomeScreen(
            showBottomNavigation: false,
            onNavigate: changePage,
          ),
          SearchScreen(
            products: HomeScreen.allAvailableProducts,
          ),
          CartScreen(
            showBottomNavigation: false,
            onNavigate: changePage,
            onBack: () {
              changePage(0);
            },
          ),
          ProfileScreen(
            showBottomNavigation: false,
            onNavigate: changePage,
            onBack: () {
              changePage(0);
            },
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 65,
        decoration: const BoxDecoration(
          color: Color(0xFF0C1425),
          border: Border(
            top: BorderSide(color: Colors.white12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            bottomItem(Icons.home_outlined, 'Home', 0),
            bottomItem(Icons.search, 'Browse', 1),
            bottomItem(Icons.shopping_cart_outlined, 'Cart', 2),
            bottomItem(Icons.person_outline, 'Profile', 3),
          ],
        ),
      ),
    );
  }

  Widget bottomItem(
    IconData icon,
    String title,
    int index,
  ) {
    final bool selected = selectedIndex == index;

    return GestureDetector(
      onTap: () => changePage(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 75,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected
                  ? const Color(0xFFFF7200)
                  : Colors.white54,
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              title,
              style: TextStyle(
                color: selected
                    ? const Color(0xFFFF7200)
                    : Colors.white54,
                fontSize: 10,
                fontWeight:
                    selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}