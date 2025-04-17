import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'exercise_progress_page.dart';

class ExercisesPage extends StatelessWidget {
  final String uid;

  const ExercisesPage({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Exercises")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('exercises')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No exercises saved."));
          }

          final exercises = snapshot.data!.docs;

          return ListView.builder(
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              final exerciseName = exercises[index].id;
              return ListTile(
                title: Text(exerciseName),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ExerciseProgressPage(
                        uid: uid,
                        exerciseName: exerciseName,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
