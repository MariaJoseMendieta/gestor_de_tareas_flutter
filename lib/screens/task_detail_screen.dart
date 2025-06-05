/*
=============================================================================
tasks_detail_screen.dart

Esta pantalla muestra la información completa de una tarea almacenada en Firestore:
Título, descripción, fecha de vencimiento, prioridad y estado.
Permite editar o eliminar la tarea desde un menú desplegable.
Convierte la tarea a formato JSON e imprime en consola.
Muestra colores indicativos para prioridad y estado.
=============================================================================
*/

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestor_de_tareas_flutter/constants.dart';
import 'package:gestor_de_tareas_flutter/screens/update_task_screen.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

/// Pantalla de detalles de una tarea almacenada en Firestore.
class TaskDetailScreen extends StatefulWidget {
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

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  /// Devuelve un color dependiendo de la prioridad.
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

  /// Devuelve un color dependiendo del estado.
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

  /// Elimina la tarea tras confirmación del usuario.
  Future<void> _deleteTask() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(kDeleteConfirmationTitle),
            content: Text(kDeleteConfirmationMessage),
            actions: [
              TextButton(
                child: Text(kCancelLabel, style: TextStyle(color: kMainColor)),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: Text(kDeleteLabel, style: TextStyle(color: kMainColor)),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
    );
    if (shouldDelete == true) {
      try {
        // Eliminar documento de Firestore
        await FirebaseFirestore.instance
            .collection(kTasksCollection)
            .doc(widget.documentId)
            .delete();

        // Verifica si el widget sigue montado
        if (!mounted) return;

        // Cerrar la pantalla de detalles
        Navigator.of(context).pop();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar la tarea. Intente de nuevo.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dueDateTime = widget.dueDate?.toDate() ?? DateTime.now();

    // Formatear solo la fecha en formato YYYY-MM-DD
    final formattedDateForJson = DateFormat('yyyy-MM-dd').format(dueDateTime);

    // Convertir los datos a JSON
    final Map<String, dynamic> taskAsJson = {
      'task_id': widget.documentId,
      'title': widget.title,
      'description': widget.description,
      'dueDate': formattedDateForJson,
      'priority': widget.priority,
      'status': widget.status,
      'origin_framework': 'flutter',
      'user_email': 'majomendieta5@gmail.com',
    };

    // Imprime la tarea como JSON con formato legible
    const encoder = JsonEncoder.withIndent('  ');
    print('Tarea en formato JSON:\n${encoder.convert(taskAsJson)}');

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles de la Tarea', style: kTextStyleAppBar),
        backgroundColor: kMainColor,
        iconTheme: kIconThemeColor,
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
                          documentId: widget.documentId,
                          title: widget.title,
                          description: widget.description,
                          dueDate: widget.dueDate,
                          priority: widget.priority,
                          status: widget.status,
                        ),
                  ),
                );
              } else if (value == 'delete') {
                // Acción para eliminar la tarea
                _deleteTask();
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
        child: ListView(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Visualización Título
                Text("Título:", style: kTextStyleDetailScreen),
                Text(widget.title),
                SizedBox(height: 16),
                // Visualización Descripción
                Text("Descripción:", style: kTextStyleDetailScreen),
                Text(widget.description ?? 'Sin descripción'),
                SizedBox(height: 16),
                // Visualización Fecha de Vencimiento
                Text("Fecha de vencimiento:", style: kTextStyleDetailScreen),
                Text(
                  widget.dueDate!.toDate().isBefore(
                        DateTime(
                          DateTime.now().year,
                          DateTime.now().month,
                          DateTime.now().day,
                        ),
                      )
                      ? '${DateFormat('dd/MM/yyyy').format(widget.dueDate!.toDate())} - Vencida'
                      : DateFormat(
                        'dd/MM/yyyy',
                      ).format(widget.dueDate!.toDate()),
                ),
                SizedBox(height: 16),
                // Visualización Prioridad
                Text("Prioridad:", style: kTextStyleDetailScreen),
                Card(
                  color: _getPriorityColor(widget.priority),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.priority,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                // Visualización Estado
                Text("Estado:", style: kTextStyleDetailScreen),
                Card(
                  color: _getStatusColor(widget.status),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.status,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
