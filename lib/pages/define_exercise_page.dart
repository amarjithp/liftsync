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
    if (_nameController.text.isEmpty || _selectedCategory == null || _selectedBodyPart == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    String exerciseName = _nameController.text.trim(); // Get exercise name

    try {
      final user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance
          .collection('users') // Go inside the users collection
          .doc(user!.uid) // Store under the logged-in user's UID
          .collection('exercises') // Save exercises inside user's exercises collection
          .doc(exerciseName) // Use exercise name as document ID instead of random ID
          .set({
        'name': exerciseName,
        'category': _selectedCategory,
        'bodyPart': _selectedBodyPart,
      });

      Navigator.pop(context); // Go back to AddExercisesPage
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving exercise")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Define Exercise'),
        actions: [IconButton(icon: Icon(Icons.check), onPressed: _saveExercise)],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Exercise Name'),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField(
              value: _selectedCategory,
              items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (value) => setState(() => _selectedCategory = value!),
              decoration: InputDecoration(labelText: 'Category'),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField(
              value: _selectedBodyPart,
              items: bodyParts.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
              onChanged: (value) => setState(() => _selectedBodyPart = value!),
              decoration: InputDecoration(labelText: 'Body Part'),
            ),
          ],
        ),
      ),
    );
  }
}