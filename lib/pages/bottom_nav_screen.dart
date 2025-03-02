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

  // List of screens for each bottom nav item
  final List<Widget> _pages = [
    ProfilePage(),
    HistoryPage(),
    HomePage(), // Workout Page
    ExercisesPage(),
    MeasuresPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      if(index < _pages.length) {
        _selectedIndex = index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,// Keeps state of all pages
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped, // Handles tab switching
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
