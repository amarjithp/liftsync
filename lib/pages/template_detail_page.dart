import 'package:flutter/material.dart';
import 'workout_tracking_page.dart';

class TemplateDetailPage extends StatelessWidget {
  final Map<String, dynamic> templateData;

  const TemplateDetailPage({super.key, required this.templateData});

  @override
  Widget build(BuildContext context) {
    final rawExercises = templateData['exercises'] as List<dynamic>;

    // 🔧 Convert sets into a list of maps for WorkoutTrackingPage
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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          templateData['title'],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Last performed

            const SizedBox(height: 20),

            // Exercises List
            Expanded(
              child: ListView.separated(
                itemCount: rawExercises.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final exercise = rawExercises[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      leading: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "${exercise['sets']}×",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      title: Text(
                        exercise['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),

                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Start Workout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
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
                icon: const Icon(Icons.fitness_center, color: Colors.white),
                label: const Text(
                  "START WORKOUT",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 1,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
