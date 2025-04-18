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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.deepPurple.withOpacity(0.1),
                    backgroundImage: profileImageUrl != null ? NetworkImage(profileImageUrl!) : null,
                    child: profileImageUrl == null
                        ? const Icon(Icons.person, size: 32, color: Colors.deepPurple)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      user.displayName ?? user.email ?? 'User',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Bio Card
              _buildEditableCard(
                title: 'Bio',
                isEditing: isEditingBio,
                controller: bioController,
                onEdit: () => setState(() {
                  isEditingBio = true;
                  bioController.text = bio;
                }),
                onChanged: () {
                  setState(() {
                    bioChanged = bioController.text.trim() != bio;
                  });
                },
                onSave: saveBio,
                contentText: bio,
                changed: bioChanged,
                hint: 'Write a short bio...',
              ),

              const SizedBox(height: 24),

              // Motivation Card
              _buildEditableCard(
                title: 'Motivation',
                isEditing: isEditingMotivation,
                controller: motivationController,
                onEdit: () => setState(() {
                  isEditingMotivation = true;
                  motivationController.text = motivation;
                }),
                onChanged: () {
                  setState(() {
                    motivationChanged = motivationController.text.trim() != motivation;
                  });
                },
                onSave: saveMotivation,
                contentText: motivation,
                changed: motivationChanged,
                hint: 'Write your motivational quote...',
              ),

              const SizedBox(height: 40),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    await FirebaseFirestore.instance.terminate();
                    await FirebaseFirestore.instance.clearPersistence();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const MainPage()),
                    );
                  },
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text('Log Out', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableCard({
    required String title,
    required bool isEditing,
    required TextEditingController controller,
    required VoidCallback onEdit,
    required VoidCallback onChanged,
    required VoidCallback onSave,
    required String contentText,
    required bool changed,
    required String hint,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    )),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: onEdit,
                  tooltip: 'Edit $title',
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Text content or textfield
            isEditing
                ? TextField(
              controller: controller,
              maxLines: 3,
              onChanged: (_) => onChanged(),
              decoration: InputDecoration(
                hintText: hint,
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 12, horizontal: 12),
              ),
            )
                : Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                contentText.isNotEmpty
                    ? contentText
                    : 'No ${title.toLowerCase()} added.',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            if (isEditing && changed)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onSave,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.deepPurple,
                  ),
                  child: const Text('Save'),
                ),
              )
          ],
        ),
      ),
    );
  }
}
