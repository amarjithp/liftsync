import 'package:flutter/material.dart';
import 'add_exercises_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutTrackingPage extends StatefulWidget {
  final List<dynamic>? initialExercises;
  final String? templateTitle;

  const WorkoutTrackingPage({Key? key, this.initialExercises, this.templateTitle}) : super(key: key);

  @override
  _WorkoutTrackingPageState createState() => _WorkoutTrackingPageState();
}

class _WorkoutTrackingPageState extends State<WorkoutTrackingPage> {
  List<Map<String, dynamic>> exercises = [];
  late final ValueNotifier<Duration> elapsedTimeNotifier;
  late final Stopwatch stopwatch;
  late final User? user;
  late TextEditingController _workoutTitleController;

  @override
  void initState() {
    super.initState();
    stopwatch = Stopwatch()..start();
    elapsedTimeNotifier = ValueNotifier(Duration.zero);
    user = FirebaseAuth.instance.currentUser;

    exercises = widget.initialExercises != null
        ? List<Map<String, dynamic>>.from(widget.initialExercises!.map((e) {
      return {
        'name': e['name'],
        'sets': e['sets'] != null
            ? List<Map<String, dynamic>>.from(e['sets'].map((s) => Map<String, dynamic>.from(s)))
            : []
      };
    }))
        : [];

    _workoutTitleController = TextEditingController(
      text: widget.templateTitle ?? "Untitled Workout",
    );

    _startTimer();
  }

  void _startTimer() {
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        elapsedTimeNotifier.value = stopwatch.elapsed;
        _startTimer();
      }
    });
  }

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

  void _addSet(int index) {
    setState(() {
      Map<String, dynamic> newSet = {
        'kg': '',
        'reps': '',
        'timer': 120,
        'previous': '',
        'completed': false,
      };

      if (exercises[index]['sets'].isNotEmpty) {
        final lastSet = exercises[index]['sets'].last;
        newSet['kg'] = lastSet['kg'];
        newSet['reps'] = lastSet['reps'];
      }

      exercises[index]['sets'].add(newSet);
    });
  }

  void _deleteSet(int exerciseIndex, int setIndex) {
    setState(() {
      exercises[exerciseIndex]['sets'].removeAt(setIndex);
    });
  }

  void _deleteExercise(int index) {
    setState(() {
      exercises.removeAt(index);
    });
  }

  void _toggleSetCompletion(int exerciseIndex, int setIndex) {
    setState(() {
      bool current = exercises[exerciseIndex]['sets'][setIndex]['completed'] ?? false;
      exercises[exerciseIndex]['sets'][setIndex]['completed'] = !current;
    });
  }

  void _cancelWorkout() {
    Navigator.pop(context);
  }

  void _finishWorkout() async {
    if (user == null) return;

    FirebaseFirestore.instance.collection('users').doc(user!.uid).collection('workouts').add({
      'workoutName': _workoutTitleController.text.trim(),
      'startTime': DateTime.now(),
      'duration': stopwatch.elapsed.inSeconds,
      'exercises': exercises,
    });

    Navigator.pop(context);
  }

  @override
  void dispose() {
    elapsedTimeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: ValueListenableBuilder<Duration>(
          valueListenable: elapsedTimeNotifier,
          builder: (context, elapsedTime, _) {
            return Text(
              '${elapsedTime.inMinutes}:${(elapsedTime.inSeconds % 60).toString().padLeft(2, '0')}',
              style: TextStyle(color: Colors.black87),
            );
          },
        ),
        actions: [
          TextButton.icon(
            onPressed: _finishWorkout,
            icon: Icon(Icons.check, color: Colors.green),
            label: Text(
              "Finish",
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("Edit Workout Name", style: TextStyle(color: Colors.black87)),
                      content: TextField(
                        controller: _workoutTitleController,
                        autofocus: true,
                        decoration: InputDecoration(hintText: "Enter workout name"),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("CANCEL"),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {});
                            Navigator.pop(context);
                          },
                          child: const Text("SAVE"),
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
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),
                  Icon(Icons.edit, size: 18, color: Colors.grey),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: exercises.length,
              itemBuilder: (context, exerciseIndex) {
                final exercise = exercises[exerciseIndex];

                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  color: Colors.white,
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                exercise['name'],
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                            ),
                            IconButton(
                              onPressed: () => _deleteExercise(exerciseIndex),
                              icon: const Icon(Icons.delete, color: Colors.red),
                            ),
                          ],
                        ),
                        ...exercise['sets'].asMap().entries.map((entry) {
                          final setIndex = entry.key;
                          final set = entry.value;

                          return Dismissible(
                            key: UniqueKey(),
                            direction: DismissDirection.endToStart,
                            onDismissed: (direction) {
                              _deleteSet(exerciseIndex, setIndex);
                            },
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            child: Row(
                              children: [
                                Text("Set ${setIndex + 1}"),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(labelText: "Kg"),
                                    keyboardType: TextInputType.number,
                                    controller: TextEditingController(text: set['kg'].toString())
                                      ..selection = TextSelection.collapsed(offset: set['kg'].toString().length),
                                    onChanged: (value) => set['kg'] = value,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(labelText: "Reps"),
                                    keyboardType: TextInputType.number,
                                    controller: TextEditingController(text: set['reps'].toString())
                                      ..selection = TextSelection.collapsed(offset: set['reps'].toString().length),
                                    onChanged: (value) => set['reps'] = value,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(set['completed']
                                      ? Icons.check_circle
                                      : Icons.check_box_outline_blank),
                                  onPressed: () => _toggleSetCompletion(exerciseIndex, setIndex),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        TextButton(
                          onPressed: () => _addSet(exerciseIndex),
                          child: const Text("ADD SET"),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _navigateToAddExercises,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    "ADD EXERCISE",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  onPressed: _cancelWorkout,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "CANCEL WORKOUT",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
