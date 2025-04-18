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
    if (enteredValue == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('measurements')
        .doc(widget.measureName)
        .collection('history')
        .add({
      'value': enteredValue,
      'timestamp': Timestamp.now(),
    });

    _valueController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final unit = measurementUnits[widget.measureName] ?? "";

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(widget.measureName),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Measurement History",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, size: 28, color: Colors.deepPurple),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        title: const Text("Add Measurement"),
                        content: TextField(
                          controller: _valueController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Enter value ($unit)",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _addMeasurement();
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text("Save", style: TextStyle(color: Colors.white)),
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
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No records found.",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }

                final records = snapshot.data!.docs;

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: records.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final data = records[index].data();
                    final value = data['value'] ?? "N/A";
                    final timestamp = (data['timestamp'] as Timestamp).toDate();
                    final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(timestamp);

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "$value $unit",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ],
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
