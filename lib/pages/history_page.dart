import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'workout_history_detail_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("History")),
      body: user == null
          ? const Center(child: Text("No user logged in"))
          : StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .collection('workouts')
            .orderBy('startTime', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No workouts found"));
          }

          final workouts = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: workouts.length,
            itemBuilder: (context, index) {
              final workout = workouts[index].data();
              final workoutName = workout['workoutName'] ?? "Untitled Workout";
              final timestamp = workout['startTime'] as Timestamp;
              final formattedDate = timestamp is Timestamp
                  ? DateFormat('EEEE, d MMMM yyyy, hh:mm a').format(timestamp.toDate())
                  : "Unknown Date";
              final exercises = List<Map<String, dynamic>>.from(workout['exercises'] ?? []);
              final totalSets = exercises.fold(0, (sum, e) => sum + ((e['sets'].length ?? 0) as int));
              final int durationInSeconds = (workout['duration'] ?? 0) as int;
              final String formattedDuration = "${durationInSeconds ~/ 60}m ${durationInSeconds % 60}s";


              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WorkoutHistoryDetailPage(workout: workout),
                    ),
                  );
                },
                child: Card(
                  color: Colors.grey[900],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workoutName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formattedDate,
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                        const SizedBox(height: 8),
                        Column(
                          children: exercises.map((exercise) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${exercise['name']}",
                                  style: const TextStyle(color: Colors.white),
                                ),
                                Text(
                                  "${exercise['sets'].length} sets",
                                  style: TextStyle(color: Colors.grey[400]),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("$formattedDuration", style: const TextStyle(color: Colors.white)),
                            Text("$totalSets sets", style: TextStyle(color: Colors.grey[400])),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
