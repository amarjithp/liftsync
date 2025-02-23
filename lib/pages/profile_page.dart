import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:liftsync/auth/main_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = FirebaseAuth.instance.currentUser!;

  int _selectedIndex = 0; // Track the selected tab index

  // Function to handle navigation
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Add navigation logic here
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/profile'); // Stay on Profile
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/history');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/workout'); // Home Page
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/exercises');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/measure');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Signed in as: ${user.email!}"),
              MaterialButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => MainPage()),
                        (route) => false, // This removes all previous routes from the stack
                  );
                },
                color: Colors.deepPurple[200],
                child: Text("Sign Out"),
              ),
            ],
          )
      ),

      // Add Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black, // Change color as needed
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: "Workout"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Exercises"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Measure"),
        ],
      ),
    );
  }
}
