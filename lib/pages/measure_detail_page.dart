import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MeasureDetailPage extends StatefulWidget {
  final String measureName;
  const MeasureDetailPage({super.key, required this.measureName});

  @override
  _MeasureDetailPageState createState() => _MeasureDetailPageState();
}

class _MeasureDetailPageState extends State<MeasureDetailPage> {
  final user = FirebaseAuth.instance.currentUser;
  final TextEditingController _valueController = TextEditingController();

  // Mapping each measurement to its corresponding unit
  final Map<String, String> measurementUnits = {
    "Weight": "kg",
    "Body fat percentage": "%",
    "Caloric intake": "kcal",
    "Chest": "cm",
    "Left bicep": "cm",
    "Right bicep": "cm",
    "Left forearm": "cm",
    "Right forearm": "cm",
    "Waist": "cm",
    "Hips": "cm",
    "Left thigh": "cm",
    "Right thigh": "cm",
    "Left calf": "cm",
    "Right calf": "cm"
  };

  void _addMeasurement() async {
    if (user == null || _valueController.text.isEmpty) return;

    double? enteredValue = double.tryParse(_valueController.text);
    if (enteredValue == null) return; // Ensure valid number input

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('measurements')
        .doc(widget.measureName)
        .collection('history')
        .add({
      'value': enteredValue, // Save as a number
      'timestamp': Timestamp.now(),
    });

    _valueController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final unit = measurementUnits[widget.measureName] ?? ""; // Get unit

    return Scaffold(
      appBar: AppBar(title: Text(widget.measureName)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Add Measurement"),
                        content: TextField(
                          controller: _valueController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: "Enter value ($unit)"),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () {
                              _addMeasurement();
                              Navigator.pop(context);
                            },
                            child: Text("Save"),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user!.uid)
                  .collection('measurements')
                  .doc(widget.measureName)
                  .collection('history')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No records found"));
                }
                final records = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final data = records[index].data();
                    final value = data['value'] ?? "N/A";
                    final timestamp = (data['timestamp'] as Timestamp).toDate();
                    final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(timestamp);

                    return ListTile(
                      title: Text("$value $unit", style: const TextStyle(color: Colors.black)),
                      subtitle: Text(formattedDate, style: TextStyle(color: Colors.black)),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
