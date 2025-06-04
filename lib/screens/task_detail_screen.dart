import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestor_de_tareas_flutter/constants.dart';
import 'package:gestor_de_tareas_flutter/screens/update_task_screen.dart';
import 'dart:convert';

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

  void _eliminarTarea(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('¿Eliminar tarea?'),
            content: Text('Esta acción no se puede deshacer.'),
            actions: [
              TextButton(
                child: Text('Cancelar', style: TextStyle(color: kMainColor)),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: Text('Eliminar', style: TextStyle(color: kMainColor)),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
    );
    if (shouldDelete == true) {
      // Eliminar documento de Firestore
      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(documentId)
          .delete();

      // Cerrar la pantalla de detalles
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dueDateTime = dueDate?.toDate() ?? DateTime.now();
    final formattedDate =
        "${dueDateTime.day.toString().padLeft(2, '0')}/"
        "${dueDateTime.month.toString().padLeft(2, '0')}/"
        "${dueDateTime.year}";

    // Formatear solo la fecha en formato YYYY-MM-DD
    final formattedDateForJson =
        "${dueDateTime.year.toString().padLeft(4, '0')}-"
        "${dueDateTime.month.toString().padLeft(2, '0')}-"
        "${dueDateTime.day.toString().padLeft(2, '0')}";

    // Convertir los datos a JSON
    final Map<String, dynamic> taskAsJson = {
      'task_id': documentId,
      'title': title,
      'description': description,
      'dueDate': formattedDateForJson,
      'priority': priority,
      'status': status,
      'origin_framework': 'flutter',
      'user_email': 'majomendieta5@gmail.com',
    };

    // 👇 Imprime en consola
    const encoder = JsonEncoder.withIndent('  ');
    print('Tarea en formato JSON:\n${encoder.convert(taskAsJson)}');

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles de la Tarea', style: kTextStyleAppBar),
        backgroundColor: kMainColor,
        iconTheme: IconThemeData(
          color: Colors.white, // Cambia esto al color que desees
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                // Acción para editar la tarea
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => UpdateTaskScreen(
                          documentId: documentId,
                          title: title,
                          description: description,
                          dueDate: dueDate,
                          priority: priority,
                          status: status,
                        ),
                  ),
                );
              } else if (value == 'delete') {
                // Acción para eliminar la tarea
                _eliminarTarea(context);
              }
            },
            itemBuilder:
                (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(value: 'edit', child: Text('Editar')),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Text('Eliminar'),
                  ),
                ],
            icon: Icon(Icons.more_vert), // icono de 3 puntos
          ),
        ],
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
