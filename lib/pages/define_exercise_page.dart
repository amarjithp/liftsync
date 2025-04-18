import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DefineExercisePage extends StatefulWidget {
  const DefineExercisePage({super.key});

  @override
  State<DefineExercisePage> createState() => _DefineExercisePageState();
}

class _DefineExercisePageState extends State<DefineExercisePage> {
  final _nameController = TextEditingController();
  String _selectedCategory = 'Barbell';
  String _selectedBodyPart = 'Chest';

  final List<String> categories = ['Barbell', 'Dumbbell', 'Machine/Other', 'Bodyweight', 'Cardio'];
  final List<String> bodyParts = ['Chest', 'Back', 'Arms', 'Legs', 'Shoulders', 'Core'];

  Future<void> _saveExercise() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    String exerciseName = _nameController.text.trim();

    try {
      final user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('exercises')
          .doc(exerciseName)
          .set({
        'name': exerciseName,
        'category': _selectedCategory,
        'bodyPart': _selectedBodyPart,
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error saving exercise")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          'Define Exercise',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.deepPurple),
            onPressed: _saveExercise,
            tooltip: "Save Exercise",
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Exercise Details",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),

                // Exercise Name
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Exercise Name',
                    labelStyle: const TextStyle(color: Colors.black54),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Category Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    labelStyle: const TextStyle(color: Colors.black54),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedCategory = value!),
                ),

                const SizedBox(height: 20),

                // Body Part Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedBodyPart,
                  decoration: InputDecoration(
                    labelText: 'Body Part',
                    labelStyle: const TextStyle(color: Colors.black54),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: bodyParts
                      .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedBodyPart = value!),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
