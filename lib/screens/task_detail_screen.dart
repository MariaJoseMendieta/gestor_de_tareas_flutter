import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestor_de_tareas_flutter/constants.dart';

class TaskDetailScreen extends StatelessWidget {
  final String title;
  final String? description;
  final Timestamp? dueDate;
  final String priority;
  final String status;
  final String documentId;

  const TaskDetailScreen({
    super.key,
    required this.title,
    this.description,
    this.dueDate,
    required this.priority,
    required this.status,
    required this.documentId,
  });

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'alta':
        return Colors.red;
      case 'media':
        return Colors.amber;
      case 'baja':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pendiente':
        return Colors.grey;
      case 'en progreso':
        return Colors.amber;
      case 'completada':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dueDateTime = dueDate?.toDate() ?? DateTime.now();
    final formattedDate =
        "${dueDateTime.day.toString().padLeft(2, '0')}/"
        "${dueDateTime.month.toString().padLeft(2, '0')}/"
        "${dueDateTime.year}";

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles de la Tarea', style: kTextStyleAppBar),
        backgroundColor: kMainColor,
      ),
      backgroundColor: kBackgroundColorApp,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Título:", style: kTextStyleDetailScreen),
            Text(title),
            SizedBox(height: 16),
            Text("Descripción:", style: kTextStyleDetailScreen),
            Text(description ?? 'Sin descripción'),
            SizedBox(height: 16),
            Text("Fecha de vencimiento:", style: kTextStyleDetailScreen),
            Text(formattedDate),
            SizedBox(height: 16),
            Text("Prioridad:", style: kTextStyleDetailScreen),
            Card(
              color: _getPriorityColor(priority),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(priority, style: TextStyle(color: Colors.white)),
              ),
            ),
            SizedBox(height: 16),
            Text("Estado:", style: kTextStyleDetailScreen),
            Card(
              color: _getStatusColor(status),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(status, style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
