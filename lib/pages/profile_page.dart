import 'package:cloud_firestore/cloud_firestore.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Signed in as: ${user.email!}"),
              MaterialButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  await FirebaseFirestore.instance.terminate();
                  await FirebaseFirestore.instance.clearPersistence(); // Clear old user's data
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MainPage()),
                  );
                },
                color: Colors.deepPurple[200],
                child: Text("Sign Out"),
              ),
            ],
          )
      ),

    );
  }
}
