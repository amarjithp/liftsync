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

  /// ✅ Save Measurement to Firestore
  Future<void> _addMeasurement() async {
    if (user == null || _valueController.text.isEmpty) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('measurements')
          .doc(widget.measureName)
          .collection('history')
          .add({
        'value': double.tryParse(_valueController.text) ?? 0,
        'timestamp': Timestamp.now(),
      });

      _valueController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.measureName)),
      body: Column(
        children: [
          /// 🔹 Input for Adding Measurements
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Add Measurement"),
                        content: TextField(
                          controller: _valueController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: "Enter value"),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () {
                              _addMeasurement();
                              Navigator.pop(context);
                            },
                            child: const Text("Save"),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          /// 🔹 Stream to Show Measurement History
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
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No records found"));
                }

                final records = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final data = records[index].data();
                    final value = data['value'] ?? "N/A";
                    final timestamp = (data['timestamp'] as Timestamp).toDate();
                    final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(timestamp);

                    return Card(
                      child: ListTile(
                        title: Text("$value cm"),
                        subtitle: Text(formattedDate),
                      ),
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
