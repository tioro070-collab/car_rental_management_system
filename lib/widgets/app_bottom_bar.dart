import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../pages/customer/home_page.dart';
import '../pages/customer/available_cars_page.dart';
import '../pages/customer/profile_page.dart';

class AppBottomBar extends StatelessWidget {
  final int selectedIndex;

  const AppBottomBar({
    super.key,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      backgroundColor: lightGrey,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      iconSize: 30,
      onTap: (index) {
        if (index == selectedIndex) return;

        Widget page;

        if (index == 0) {
          page = const HomeScreen();
        } else if (index == 1) {
          page = const AvailableCarsScreen();
        } else {
          page = const ProfileScreen();
        }

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => page),
              (route) => false,
        );
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
