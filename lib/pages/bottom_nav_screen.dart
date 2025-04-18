import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'exercises_page.dart';
import 'measures_page.dart';
import 'profile_page.dart';
import 'history_page.dart';
import 'home_page.dart';

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  _BottomNavScreenState createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _selectedIndex = 2;

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
      ExercisesPage(uid: uid),
      MeasuresPage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          /*borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),*/
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            selectedItemColor: Colors.deepPurple,
            unselectedItemColor: Colors.grey[500],
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded),
                label: "Profile",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history_rounded),
                label: "History",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.fitness_center_rounded),
                label: "Workout",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.list_alt_rounded),
                label: "Exercises",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.straighten_rounded),
                label: "Measure",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
