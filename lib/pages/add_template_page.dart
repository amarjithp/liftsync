// add_workout_page.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_exercises_page.dart';

class AddTemplatePage extends StatefulWidget {
  const AddTemplatePage({super.key});

  @override
  _AddTemplatePageState createState() => _AddTemplatePageState();
}

class _AddTemplatePageState extends State<AddTemplatePage> {
  final TextEditingController _titleController = TextEditingController();
  List<Map<String, dynamic>> exercises = [];

  void _addExercise() async {
    final selectedExercises = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddExercisesPage()),
    );

    if (selectedExercises != null && selectedExercises is List<String>) {
      setState(() {
        for (var exercise in selectedExercises) {
          exercises.add({'name': exercise, 'sets': 1});
        }
      });
    }
  }


  void _saveWorkout() async {
    if (_titleController.text.isEmpty || exercises.isEmpty) return;
    final user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('workoutTemplates') // Store under user's templates
        .doc(_titleController.text) // Use template name as document ID
        .set({
      'title': _titleController.text,
      'exercises': exercises, // Store exercises inside the template
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Workout Template'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _saveWorkout,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Workout Template Name'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(exercises[index]['name']),
                    trailing: DropdownButton<int>(
                      value: exercises[index]['sets'],
                      onChanged: (newValue) {
                        setState(() {
                          exercises[index]['sets'] = newValue!;
                        });
                      },
                      items: List.generate(10, (i) => i + 1)
                          .map((e) => DropdownMenuItem(value: e, child: Text('$e sets')))
                          .toList(),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _addExercise,
              child: Text('Add Exercise'),
            ),
          ],
        ),
      ),
    );
  }
}
