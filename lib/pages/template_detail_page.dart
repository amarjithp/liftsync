import 'package:flutter/material.dart';
import 'workout_tracking_page.dart';

class TemplateDetailPage extends StatelessWidget {
  final Map<String, dynamic> templateData;

  const TemplateDetailPage({super.key, required this.templateData});

  @override
  Widget build(BuildContext context) {
    final rawExercises = templateData['exercises'] as List<dynamic>;

    // 🔧 Convert each exercise's sets count into a list of set maps
    final processedExercises = rawExercises.map<Map<String, dynamic>>((exercise) {
      final setsCount = exercise['sets'] is int ? exercise['sets'] : 0;

      return {
        'name': exercise['name'],
        'sets': List.generate(setsCount, (_) => {
          'kg': '',
          'reps': '',
          'timer': 120,
          'previous': '',
          'completed': false,
        }),
      };
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(templateData['title']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Last performed: ${templateData['lastPerformed'] != null ? templateData['lastPerformed'].toDate().toString().split(' ')[0] : 'Never'}",
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: rawExercises.length,
                itemBuilder: (context, index) {
                  final exercise = rawExercises[index];
                  return ListTile(
                    leading: Text("${exercise['sets']} ×"),
                    title: Text(exercise['name']),
                    subtitle: Text("Target: ${exercise['muscle'] ?? '—'}"),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WorkoutTrackingPage(
                      initialExercises: processedExercises,
                      templateTitle: templateData['title'],
                    ),
                  ),
                );
              },
              child: Text("START WORKOUT"),
            ),
          ],
        ),
      ),
    );
  }
}
