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
      final cleaned = value.trim().replaceAll(',', '.');
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
      appBar: AppBar(
        title: Text(
          workoutName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      backgroundColor: const Color(0xFFF9F9F9),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formattedDate,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  final e = exercises[index];
                  final sets = List<Map<String, dynamic>>.from(e['sets']);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${e['name']} ${e['equipment'] != null ? '(${e['equipment']})' : ''}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Column(
                          children: List.generate(sets.length, (i) {
                            final set = sets[i];
                            final double weight = parseDouble(set['kg']);
                            final int reps = parseInt(set['reps']);
                            final int oneRM = parseInt(set['1RM']);
                            final bool isPR = set['isPR'] == true;

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Set ${i + 1}: ${weight % 1 == 0 ? weight.toInt() : weight} kg × $reps reps",
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "$oneRM",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      if (isPR)
                                        const Icon(
                                          Icons.emoji_events,
                                          color: Colors.orange,
                                          size: 18,
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _statTile("Duration", formattedDuration),
                  /*_divider(),
                  _statTile("Volume", "${totalVolume.toStringAsFixed(1)} kg"),
                  _divider(),
                  _statTile("PRs", "$prs"),*/
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  "PERFORM AGAIN",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 32,
      color: Colors.grey[300],
    );
  }
}
