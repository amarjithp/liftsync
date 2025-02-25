import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:liftsync/auth/main_page.dart';
import 'package:liftsync/pages/home_page.dart';

import 'pages/profile_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "liftsync",
      home: MainPage(),
      routes: {
        '/profile': (context) => ProfilePage(),
        '/workout': (context) => HomePage(),
      },
    );
  }
}
