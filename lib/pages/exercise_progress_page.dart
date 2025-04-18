import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: Text(
            exerciseName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 1,
          iconTheme: const IconThemeData(color: Colors.black),
          bottom: const TabBar(
            labelColor: Colors.deepPurple,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.deepPurple,
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
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

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
              return const Center(
                child: Text(
                  "No data available.",
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }

            records.sort((a, b) => (double.tryParse(b['kg'].toString()) ?? 0)
                .compareTo(double.tryParse(a['kg'].toString()) ?? 0));

            String formatDate(DateTime date) {
              return DateFormat('dd MMM yyyy • hh:mm a').format(date);
            }

            Widget buildEntryCard(Map<String, dynamic> entry) {
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${entry['kg']} kg x ${entry['reps']} reps",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        formatDate(entry['date']),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return TabBarView(
              children: [
                ListView.builder(
                  itemCount: progress.length,
                  itemBuilder: (context, index) => buildEntryCard(progress[index]),
                ),
                ListView.builder(
                  itemCount: records.length,
                  itemBuilder: (context, index) => buildEntryCard(records[index]),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
