import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:liftsync/auth/auth_page.dart';
import 'package:liftsync/pages/bottom_nav_screen.dart';
import '../pages/home_page.dart';


class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if(snapshot.hasData) {
              return BottomNavScreen();
            } else {
              return AuthPage();
            }
          },
      ),
    );
  }
}
