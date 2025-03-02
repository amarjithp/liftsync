import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'measure_detail_page.dart';

class MeasuresPage extends StatelessWidget {
  final List<String> measures = [
    "Weight",
    "Body Fat Percentage",
    "Caloric Intake",
    "Chest",
    "Left Bicep",
    "Right Bicep",
    "Left Forearm"
  ];

  MeasuresPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Measurements")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: measures.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(measures[index], style: const TextStyle(fontSize: 18)),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MeasureDetailPage(measureName: measures[index]),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
