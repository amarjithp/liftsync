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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Measurements",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: measures.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MeasureDetailPage(measureName: measures[index]),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ListTile(
                title: Text(
                  measures[index],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Colors.deepPurple),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          );
        },
      ),
    );
  }
}
