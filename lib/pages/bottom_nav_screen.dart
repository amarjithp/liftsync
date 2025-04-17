import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'exercises_page.dart';
import 'measures_page.dart';
import 'profile_page.dart';
import 'history_page.dart';
import 'home_page.dart'; // The workout page

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  _BottomNavScreenState createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _selectedIndex = 2; // Default selected tab (Workout Page)

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final List<Widget> _pages = [
      const ProfilePage(),
      const HistoryPage(),
      const HomePage(),
      ExercisesPage(uid: uid), // ✅ Fixed: Pass UID properly
      MeasuresPage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: "Workout"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Exercises"),
          BottomNavigationBarItem(icon: Icon(Icons.straighten), label: "Measure"),
        ],
      ),
    );
  }
}
