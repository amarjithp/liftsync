import 'package:flutter/material.dart';
import 'add_exercises_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutTrackingPage extends StatefulWidget {
  const WorkoutTrackingPage({Key? key}) : super(key: key);

  @override
  _WorkoutTrackingPageState createState() => _WorkoutTrackingPageState();
}

class _WorkoutTrackingPageState extends State<WorkoutTrackingPage> {
  List<Map<String, dynamic>> exercises = []; // Stores selected exercises
  bool isMinimized = false;
  DateTime startTime = DateTime.now();
  Duration elapsedTime = Duration.zero;
  late final Stopwatch stopwatch;
  late final User? user;
  TextEditingController _workoutTitleController = TextEditingController(text: "Untitled Workout");

  @override
  void initState() {
    super.initState();
    stopwatch = Stopwatch()..start();
    user = FirebaseAuth.instance.currentUser;
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          elapsedTime = stopwatch.elapsed;
        });
        _startTimer();
      }
    });
  }

  // 🚀 Handle Add Exercise Button Click
  Future<void> _navigateToAddExercises() async {
    final selectedExerciseNames = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddExercisesPage()),
    );

    if (selectedExerciseNames != null) {
      setState(() {
        for (String name in selectedExerciseNames) {
          if (!exercises.any((e) => e['name'] == name)) {
            exercises.add({
              'name': name,
              'sets': [],
            });
          }
        }
      });
    }
  }

  // 🚀 Add a New Set to an Exercise
  void _addSet(int index) {
    setState(() {
      exercises[index]['sets'].add({
        'kg': '',
        'reps': '',
        'timer': 120, // Default rest time
        'previous': '',
        'completed': false,
      });
    });
  }

  // 🚀 Toggle Set Completion & Start Timer for Next Set
  void _toggleSetCompletion(int exerciseIndex, int setIndex) {
    setState(() {
      exercises[exerciseIndex]['sets'][setIndex]['completed'] = true;

      if (setIndex + 1 < exercises[exerciseIndex]['sets'].length) {
        Future.delayed(
          Duration(seconds: exercises[exerciseIndex]['sets'][setIndex]['timer']),
              () {
            setState(() {
              exercises[exerciseIndex]['sets'][setIndex + 1]['completed'] = false;
            });
          },
        );
      }
    });
  }

  // 🚀 Cancel Workout
  void _cancelWorkout() {
    Navigator.pop(context);
  }

  // 🚀 Save Workout to Firestore
  void _finishWorkout() async {
    if (user == null) return;
    FirebaseFirestore.instance.collection('users').doc(user!.uid).collection('workouts').add({
      'workoutName': _workoutTitleController.text.trim(),
      'startTime': startTime,
      'duration': stopwatch.elapsed.inSeconds,
      'exercises': exercises,
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${elapsedTime.inMinutes}:${(elapsedTime.inSeconds % 60).toString().padLeft(2, '0')}',
        ),
        actions: [
          TextButton(
            onPressed: _finishWorkout,
            child: Text("FINISH", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Workout Title (Editable)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("Edit Workout Name"),
                      content: TextField(
                        controller: _workoutTitleController,
                        autofocus: true,
                        decoration: InputDecoration(hintText: "Enter workout name"),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("CANCEL"),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {});
                            Navigator.pop(context);
                          },
                          child: Text("SAVE"),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _workoutTitleController.text,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Icon(Icons.edit, size: 18, color: Colors.grey),
                ],
              ),
            ),
          ),

          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('${elapsedTime.inMinutes}:${(elapsedTime.inSeconds % 60).toString().padLeft(2, '0')}'),
          ),

          // Buttons
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _navigateToAddExercises,
                  child: Text("ADD EXERCISE"),
                ),
                ElevatedButton(
                  onPressed: _cancelWorkout,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text("CANCEL WORKOUT"),
                ),
              ],
            ),
          ),

          // Exercise List
          Expanded(
            child: ListView.builder(
              itemCount: exercises.length,
              itemBuilder: (context, exerciseIndex) {
                final exercise = exercises[exerciseIndex];

                return Card(
                  margin: EdgeInsets.all(12),
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(exercise['name'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ...exercise['sets'].asMap().entries.map((entry) {
                          final setIndex = entry.key;
                          final set = entry.value;

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Set ${setIndex + 1}"),
                              SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(labelText: "Kg"),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) => set['kg'] = value,
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(labelText: "Reps"),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) => set['reps'] = value,
                                ),
                              ),
                              IconButton(
                                icon: Icon(set['completed'] ? Icons.check_circle : Icons.check_box_outline_blank),
                                onPressed: () => _toggleSetCompletion(exerciseIndex, setIndex),
                              ),
                            ],
                          );
                        }).toList(),
                        TextButton(
                          onPressed: () => _addSet(exerciseIndex),
                          child: Text("ADD SET"),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
