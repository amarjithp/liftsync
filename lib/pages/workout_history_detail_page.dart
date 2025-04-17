import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'workout_tracking_page.dart';

class WorkoutHistoryDetailPage extends StatelessWidget {
  final Map<String, dynamic> workout;

  const WorkoutHistoryDetailPage({super.key, required this.workout});

  int parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  double parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final cleaned = value.trim().replaceAll(',', '.'); // just in case commas are used
      final parsed = double.tryParse(cleaned);
      if (parsed == null) {
        debugPrint("Failed to parse weight: '$value'");
        return 0.0;
      }
      return parsed;
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    print('Workout data: $workout');
    final workoutName = workout['workoutName'] ?? "Untitled Workout";
    final timestamp = workout['startTime'] as Timestamp?;
    final formattedDate = timestamp != null
        ? DateFormat('EEEE, d MMMM yyyy, hh:mm a').format(timestamp.toDate())
        : "Unknown Date";

    final duration = parseInt(workout['duration']);
    final formattedDuration = "${duration ~/ 60}m ${duration % 60}s";

    final exercises = List<Map<String, dynamic>>.from(workout['exercises'] ?? []);
    double totalVolume = 0;
    int totalSets = 0;
    int prs = 0;

    for (var e in exercises) {
      final sets = List<Map<String, dynamic>>.from(e['sets']);
      for (var set in sets) {
        final double weight = parseDouble(set['kg']);
        final int reps = parseInt(set['reps']);
        totalVolume += weight * reps;
        totalSets += 1;
        if (set['isPR'] == true) prs++;
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(workoutName)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(formattedDate, style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  final e = exercises[index];
                  final sets = List<Map<String, dynamic>>.from(e['sets']);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${e['name']} ${e['equipment'] != null ? '(${e['equipment']})' : ''}",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Column(
                        children: List.generate(sets.length, (i) {
                          final set = sets[i];
                          final double weight = parseDouble(set['kg']);
                          final int reps = parseInt(set['reps']);
                          final int oneRM = parseInt(set['1RM']);
                          final bool isPR = set['isPR'] == true;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("${i + 1}  ${weight % 1 == 0 ? weight.toInt() : weight} kg × $reps"),
                                Row(
                                  children: [
                                    Text("$oneRM", style: TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 4),
                                    if (isPR)
                                      const Icon(Icons.emoji_events, color: Colors.orange, size: 18),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 12),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(formattedDuration),
                Text("${totalVolume.toStringAsFixed(1)} kg"),
                Text("$prs PRs"),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WorkoutTrackingPage(
                      initialExercises: exercises,
                      templateTitle: workoutName,
                    ),
                  ),
                );
              },
              child: const Text("PERFORM AGAIN"),
            ),
          ],
        ),
      ),
    );
  }
}
