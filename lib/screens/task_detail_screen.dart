import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskDetailScreen extends StatelessWidget {
  final String title;
  final String? description;
  final Timestamp? dueDate;
  final String priority;
  final String status;

  const TaskDetailScreen({
    super.key,
    required this.title,
    this.description,
    this.dueDate,
    required this.priority,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final dueDateTime = dueDate?.toDate() ?? DateTime.now();
    final formattedDate =
        "${dueDateTime.day.toString().padLeft(2, '0')}/"
        "${dueDateTime.month.toString().padLeft(2, '0')}/"
        "${dueDateTime.year}";

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles de la Tarea'),
        backgroundColor: Color(0xFF0569B4),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Título:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(title),
            SizedBox(height: 16),
            Text("Descripción:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(description ?? 'Sin descripción'),
            SizedBox(height: 16),
            Text(
              "Fecha de entrega:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(formattedDate),
            SizedBox(height: 16),
            Text("Prioridad:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(priority),
            SizedBox(height: 16),
            Text("Estado:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(status),
          ],
        ),
      ),
    );
  }
}
