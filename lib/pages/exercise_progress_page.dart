import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ExerciseProgressPage extends StatelessWidget {
  final String uid;
  final String exerciseName;

  const ExerciseProgressPage({
    super.key,
    required this.uid,
    required this.exerciseName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(exerciseName)),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('workouts')
            .orderBy('startTime', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final workouts = snapshot.data!.docs;
          final List<Map<String, dynamic>> progress = [];

          for (var workout in workouts) {
            final exercises = List<Map<String, dynamic>>.from(workout['exercises']);
            for (var exercise in exercises) {
              if (exercise['name'] == exerciseName) {
                final sets = List<Map<String, dynamic>>.from(exercise['sets']);
                for (var set in sets) {
                  progress.add({
                    'kg': set['kg'],
                    'reps': set['reps'],
                    'date': workout['startTime'].toDate(),
                  });
                }
              }
            }
          }

          if (progress.isEmpty) {
            return const Center(child: Text("No data available."));
          }

          return ListView.builder(
            itemCount: progress.length,
            itemBuilder: (context, index) {
              final entry = progress[index];
              return ListTile(
                title: Text("${entry['kg']} kg x ${entry['reps']} reps"),
                subtitle: Text(entry['date'].toString()),
              );
            },
          );
        },
      ),
    );
  }
}
