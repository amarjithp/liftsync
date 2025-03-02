import 'package:flutter/material.dart';
import 'package:liftsync/pages/measure_detail_page.dart';

class MeasuresPage extends StatelessWidget {
  final List<String> measures = [
    "Weight",
    "Body fat percentage",
    "Caloric intake",
    "Chest",
    "Left bicep",
    "Right bicep",
    "Left forearm",
    "Right forearm",
    "Waist",
    "Hips",
    "Left thigh",
    "Right thigh",
    "Left calf",
    "Right calf"
  ];

  MeasuresPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Measure")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: measures.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(measures[index], style: TextStyle(fontSize: 18)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MeasureDetailPage(measureName: measures[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
