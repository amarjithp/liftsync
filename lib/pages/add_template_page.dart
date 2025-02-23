// add_workout_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddTemplatePage extends StatefulWidget {
  const AddTemplatePage({super.key});

  @override
  _AddTemplatePageState createState() => _AddTemplatePageState();
}

class _AddTemplatePageState extends State<AddTemplatePage> {
  final TextEditingController _titleController = TextEditingController();
  List<Map<String, dynamic>> exercises = [];

  void _addExercise() {
    setState(() {
      exercises.add({'name': '', 'sets': 1});
    });
  }

  void _saveWorkout() async {
    if (_titleController.text.isEmpty || exercises.isEmpty) return;

    await FirebaseFirestore.instance.collection('workoutTemplates').doc(_titleController.text).set({
      'title': _titleController.text,
      'lastPerformed': 'Never',
      'exercises': exercises,
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
                    title: TextField(
                      onChanged: (value) => exercises[index]['name'] = value,
                      decoration: InputDecoration(labelText: 'Exercise Name'),
                    ),
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
