import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:project_eatup/buttonscreen/home_screen.dart';
import 'package:project_eatup/buttonscreen/order_screen.dart';
import 'package:project_eatup/buttonscreen/profile_screen.dart';
import 'package:project_eatup/buttonscreen/search_screen.dart';

class DashboardScreen extends StatefulWidget {
  
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int index = 2;

  final List<Widget> screens = const [
    SearchScreen(),
    SearchScreen(),
    HomeScreen(),
    OrderScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      const Icon(Icons.search, size: 30, color: Colors.white),
      const Icon(Icons.hourglass_bottom, size: 30, color: Colors.white),
      const Icon(Icons.home, size: 30, color: Colors.white),
      const Icon(Icons.shopping_basket_rounded, size: 30, color: Colors.white),
      const Icon(Icons.person, size: 30, color: Colors.white),
    ];

    return Scaffold(
      
      appBar: AppBar(
        title: const Text('Dashboard Screen'),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
      ),

      // 👇 Screen switching logic
      body: screens[index],

      bottomNavigationBar: CurvedNavigationBar(
        items: items,
        index: index,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        color: Colors.deepOrange,
        buttonBackgroundColor: Colors.deepOrange,
        animationDuration: const Duration(milliseconds: 300),
        onTap: (selectedIndex) {
          setState(() {
            index = selectedIndex;
          });
        },
      ),
    );
  }
}
