import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'define_exercise_page.dart';


class AddExercisesPage extends StatefulWidget {
  const AddExercisesPage({super.key});

  @override
  State<AddExercisesPage> createState() => _AddExercisesPageState();
}

class _AddExercisesPageState extends State<AddExercisesPage> {
  List<Map<String, dynamic>> exercises = [];
  List<String> _selectedExercises = [];


  @override
  void initState() {
    super.initState();
    _fetchExercises();
  }

  void _fetchExercises() async {
    final user = FirebaseAuth.instance.currentUser; // Get the logged-in user
    if (user == null) return; // Safety check

    final snapshot = await FirebaseFirestore.instance
        .collection('users') // Access users collection
        .doc(user.uid) // Get the logged-in user's document
        .collection('exercises') // Fetch exercises specific to that user
        .get();

    setState(() {
      exercises = snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  void _toggleSelection(String exerciseName) {
    setState(() {
      if (_selectedExercises.contains(exerciseName)) {
        _selectedExercises.remove(exerciseName);
      } else {
        _selectedExercises.add(exerciseName);
      }
    });
  }

  void _navigateToDefineExercise() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DefineExercisePage()),
    );
    _fetchExercises(); // Refresh list after adding new exercise
  }

  void _showSearch() async {
    final result = await showSearch(
      context: context,
      delegate: ExerciseSearchDelegate(exercises),
    );
    if (result != null) {
      print('Selected exercise: $result');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Exercises'),
        actions: _selectedExercises.isNotEmpty
            ? [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              Navigator.pop(context, _selectedExercises);
            },
          ),
        ] :[
          IconButton(icon: Icon(Icons.search), onPressed: _showSearch),
          IconButton(icon: Icon(Icons.add), onPressed: _navigateToDefineExercise),
        ],
      ),
      body: ListView.builder(
        itemCount: exercises.length,
        itemBuilder: (context, index) {
          final exercise = exercises[index];
          return ListTile(
            leading: Icon(Icons.fitness_center),
            title: Text(exercise['name']),
            subtitle: Text('${exercise['category']} • ${exercise['bodyPart']}'),
            trailing: _selectedExercises.contains(exercise['name'])
                ? Icon(Icons.check_circle, color: Colors.green)
                : null,
            onTap: () => _toggleSelection(exercise['name']),
          );
        },
      ),
    );
  }
}

// Search Delegate
class ExerciseSearchDelegate extends SearchDelegate<String> {
  final List<Map<String, dynamic>> exercises;
  ExerciseSearchDelegate(this.exercises);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [IconButton(icon: Icon(Icons.clear), onPressed: () => query = '')];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(icon: Icon(Icons.arrow_back), onPressed: () => close(context, ''));
  }

  @override
  Widget buildResults(BuildContext context) => _buildList();
  @override
  Widget buildSuggestions(BuildContext context) => _buildList();

  Widget _buildList() {
    final filtered = exercises.where((e) => e['name'].toLowerCase().contains(query.toLowerCase())).toList();
    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final exercise = filtered[index];
        return ListTile(
          title: Text(exercise['name']),
          subtitle: Text('${exercise['category']} • ${exercise['bodyPart']}'),
          onTap: () => close(context, exercise['name']),
        );
      },
    );
  }
}