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
  String? profileImageUrl;

  String bio = '';
  String motivation = '';
  bool isEditingBio = false;
  bool isEditingMotivation = false;
  bool bioChanged = false;
  bool motivationChanged = false;

  final bioController = TextEditingController();
  final motivationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProfileData();
  }

  Future<void> loadProfileData() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('profilepage')
        .doc('data')
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        bio = data['bio'] ?? '';
        motivation = data['motivation'] ?? '';
        bioController.text = bio;
        motivationController.text = motivation;
      });
    }
  }

  Future<void> saveBio() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('profilepage')
        .doc('data')
        .set({'bio': bioController.text.trim()}, SetOptions(merge: true));

    setState(() {
      bio = bioController.text.trim();
      isEditingBio = false;
      bioChanged = false;
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Bio updated')));
  }

  Future<void> saveMotivation() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('profilepage')
        .doc('data')
        .set({'motivation': motivationController.text.trim()}, SetOptions(merge: true));

    setState(() {
      motivation = motivationController.text.trim();
      isEditingMotivation = false;
      motivationChanged = false;
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Motivation updated')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Header with avatar and username
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: profileImageUrl != null
                        ? NetworkImage(profileImageUrl!)
                        : null,
                    child: profileImageUrl == null
                        ? const Icon(Icons.person, size: 30)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      user.displayName ?? user.email ?? 'User',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Bio section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Bio',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Transform.scale(
                    scale: 0.7,
                    child: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        setState(() {
                          isEditingBio = true;
                          bioController.text = bio;
                        });
                      },
                    ),
                  ),
                ],
              ),
              if (isEditingBio)
                TextField(
                  controller: bioController,
                  maxLines: 2,
                  onChanged: (_) {
                    setState(() {
                      bioChanged = bioController.text.trim() != bio;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Write a short bio...',
                    border: OutlineInputBorder(),
                  ),
                )
              else
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    bio.isNotEmpty ? bio : 'No bio added.',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (isEditingBio && bioChanged)
                TextButton(
                  onPressed: saveBio,
                  child: const Text('Save'),
                ),

              const SizedBox(height: 24),

              // Motivation section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Motivation',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Transform.scale(
                    scale: 0.7,
                    child: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        setState(() {
                          isEditingMotivation = true;
                          motivationController.text = motivation;
                        });
                      },
                    ),
                  ),
                ],
              ),
              if (isEditingMotivation)
                TextField(
                  controller: motivationController,
                  maxLines: 2,
                  onChanged: (_) {
                    setState(() {
                      motivationChanged =
                          motivationController.text.trim() != motivation;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Write your motivational quote...',
                    border: OutlineInputBorder(),
                  ),
                )
              else
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    motivation.isNotEmpty
                        ? motivation
                        : 'No motivation quote added.',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (isEditingMotivation && motivationChanged)
                TextButton(
                  onPressed: saveMotivation,
                  child: const Text('Save'),
                ),

              const Spacer(),

              // Logout button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    await FirebaseFirestore.instance.terminate();
                    await FirebaseFirestore.instance.clearPersistence();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const MainPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Log Out'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
