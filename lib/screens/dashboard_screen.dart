import 'dart:async'; // ✅ 1. Needed for listening to the sensor stream
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:shake/shake.dart';
import 'package:proximity_sensor/proximity_sensor.dart'; // ✅ 2. Import proximity sensor

// Your screen imports
import 'package:project_eatup/buttonscreen/home_screen.dart';
import 'package:project_eatup/buttonscreen/order_screen.dart';
import 'package:project_eatup/buttonscreen/profile_screen.dart';
import 'package:project_eatup/buttonscreen/search_screen.dart';
import 'package:project_eatup/buttonscreen/previous_order_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int index = 2; // Starts on HomeScreen!
  
  // Hardware listeners
  late ShakeDetector _shakeDetector;
  late StreamSubscription<dynamic> _proximitySubscription;
  
  // State for the black-out effect
  bool _isScreenBlackedOut = false;

  final List<Widget> screens = [
    const SearchScreen(),
    const PreviousOrderScreen(), 
    const HomeScreen(),   
    const OrderScreen(), 
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    
    // 📳 START SHAKE DETECTOR
   _shakeDetector = ShakeDetector.autoStart(
      // 👇 THE FIX IS HERE: Added 'event' inside the parentheses!
      onPhoneShake: (event) { 
        if (!mounted) return;
        setState(() {
          index = 3; // Jump to OrderScreen
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📳 Shake detected! Jumping to your orders.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      },
      shakeSlopTimeMS: 500, 
      shakeCountResetTime: 3000, 
      shakeThresholdGravity: 2.7, 
    );

    // 👤 START PROXIMITY SENSOR
    // This listens to the hardware sensor near your front camera
    _proximitySubscription = ProximitySensor.events.listen((int event) {
      if (!mounted) return;
      
      setState(() {
        // The sensor usually returns 1 if something is near, and 0 if clear.
        // We set _isScreenBlackedOut to true if it detects an object.
        _isScreenBlackedOut = (event > 0); 
      });
    });
  }

  @override
  void dispose() {
    // 🛑 ALWAYS clean up hardware listeners when closing the screen!
    _shakeDetector.stopListening();
    _proximitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🕶️ THE BLACKOUT OVERLAY LOGIC
    // If the sensor is covered, we return a completely black screen.
    if (_isScreenBlackedOut) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: SizedBox.shrink(), // Renders absolutely nothing
      );
    }

    // 📱 NORMAL UI LOGIC (If sensor is NOT covered)
    final items = <Widget>[
      const Icon(Icons.search, size: 30, color: Colors.white),
      const Icon(Icons.hourglass_bottom, size: 30, color: Colors.white),
      const Icon(Icons.home, size: 30, color: Colors.white),
      const Icon(Icons.shopping_basket_rounded, size: 30, color: Colors.white),
      const Icon(Icons.person, size: 30, color: Colors.white),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Eat Up'),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
      ),

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