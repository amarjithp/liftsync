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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('exercises')
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
    _fetchExercises();
  }

  void _showSearch() async {
    final result = await showSearch(
      context: context,
      delegate: ExerciseSearchDelegate(exercises),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.deepPurple),
        title: const Text(
          'Add Exercises',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: _selectedExercises.isNotEmpty
            ? [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.deepPurple),
            onPressed: () {
              Navigator.pop(context, _selectedExercises);
            },
          ),
        ]
            : [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.deepPurple),
            onPressed: _showSearch,
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.deepPurple),
            onPressed: _navigateToDefineExercise,
          ),
        ],
      ),
      body: exercises.isEmpty
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: exercises.length,
        itemBuilder: (context, index) {
          final exercise = exercises[index];
          final isSelected = _selectedExercises.contains(exercise['name']);

          return GestureDetector(
            onTap: () => _toggleSelection(exercise['name']),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: isSelected ? Colors.deepPurple : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.fitness_center, color: Colors.deepPurple),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise['name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${exercise['category']} • ${exercise['bodyPart']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle, color: Colors.green),
                ],
              ),
            ),
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
    return [IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, ''));
  }

  @override
  Widget buildResults(BuildContext context) => _buildList();
  @override
  Widget buildSuggestions(BuildContext context) => _buildList();

  Widget _buildList() {
    final filtered = exercises
        .where((e) => e['name'].toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final exercise = filtered[index];
        return ListTile(
          leading: const Icon(Icons.fitness_center, color: Colors.deepPurple),
          title: Text(
            exercise['name'],
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text('${exercise['category']} • ${exercise['bodyPart']}'),
          onTap: () => close(context, exercise['name']),
        );
      },
    );
  }
}
