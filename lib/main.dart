import 'package:flutter/material.dart';

// === IMPORT FILE LAIN ===
import 'Dashboard.dart';
import 'HealthMetrics.dart';
import 'EmergencyContacts.dart';
import 'Medications.dart';
import 'Welcome.dart';

void main() {
  runApp(const CareRingApp());
}

class CareRingApp extends StatelessWidget {
  const CareRingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CareRing',
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF87CEEB),
        scaffoldBackgroundColor: const Color(0xFFE8E8E8),
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool showWelcome = true;
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {

    // === WELCOME SCREEN ===
    if (showWelcome) {
      return WelcomeScreen(
        onGetStarted: () {
          setState(() {
            showWelcome = false;
          });
        },
      );
    }

    // === LIST HALAMAN ===
    final screens = [
      Dashboard(),
      HealthMetrics(),
      EmergencyContacts(),
      Medications(),
    ];

    return Scaffold(
      // === FIX OVERFLOW: SafeArea + SizedBox.expand ===
      body: SafeArea(
        child: SizedBox.expand(
          child: screens[currentIndex],
        ),
      ),

      // === BOTTOM NAV ===
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Health",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: "Contacts",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medication),
            label: "Meds",
          ),
        ],
      ),
    );
  }
}
