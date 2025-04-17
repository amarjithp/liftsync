import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

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
    return DefaultTabController(
      length: 2, // History and Records
      child: Scaffold(
        appBar: AppBar(
          title: Text(exerciseName),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'HISTORY'),
              Tab(text: 'RECORDS'),
            ],
          ),
        ),
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
            final List<Map<String, dynamic>> records = [];

            for (var workout in workouts) {
              final exercises = List<Map<String, dynamic>>.from(workout['exercises']);
              for (var exercise in exercises) {
                if (exercise['name'] == exerciseName) {
                  final sets = List<Map<String, dynamic>>.from(exercise['sets']);
                  for (var set in sets) {
                    final entry = {
                      'kg': set['kg'],
                      'reps': set['reps'],
                      'date': workout['startTime'].toDate(),
                    };
                    progress.add(entry);
                    records.add(entry);
                  }
                }
              }
            }

            if (progress.isEmpty) {
              return const Center(child: Text("No data available."));
            }

            // Sort records by weight (kg), highest first
            records.sort((a, b) => b['kg'].compareTo(a['kg']));

            String formatDate(DateTime date) {
              return DateFormat('dd MMM yyyy • hh:mm a').format(date);
            }

            return TabBarView(
              children: [
                // HISTORY TAB
                ListView.builder(
                  itemCount: progress.length,
                  itemBuilder: (context, index) {
                    final entry = progress[index];
                    return ListTile(
                      title: Text("${entry['kg']} kg x ${entry['reps']} reps"),
                      subtitle: Text(formatDate(entry['date'])),
                    );
                  },
                ),

                // RECORDS TAB
                ListView.builder(
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final entry = records[index];
                    return ListTile(
                      title: Text("${entry['kg']} kg x ${entry['reps']} reps"),
                      subtitle: Text(formatDate(entry['date'])),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
