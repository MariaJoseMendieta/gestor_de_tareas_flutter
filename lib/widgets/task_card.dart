/*
=============================================================================
task_card.dart

Widget que representa una tarjeta visual para mostrar la información de una
tarea.
Permite mostrar el título, descripción, fecha de vencimiento, prioridad y
estado de la tarea.
También ofrece acciones para eliminar, editar y ver detalles de la tarea.
=============================================================================
*/

import 'package:flutter/material.dart';
import 'package:gestor_de_tareas_flutter/constants.dart';
import 'package:gestor_de_tareas_flutter/screens/task_detail_screen.dart';
import 'package:gestor_de_tareas_flutter/screens/update_task_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TaskCard extends StatefulWidget {
  const TaskCard({
    super.key,
    required this.title,
    this.description,
    this.dueDate,
    this.priority = 'Media',
    this.status = 'Pendiente',
    required this.documentId,
  });

  final String title;
  final String? description;
  final Timestamp? dueDate;
  final String priority;
  final String status;
  final String documentId;
  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  /// Devuelve el color asociado a la prioridad de la tarea.
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

  /// Devuelve el color asociado al estado de la tarea.
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

  /// Muestra un diálogo de confirmación para eliminar la tarea.
  ///
  /// Si el usuario confirma, elimina el documento de Firestore correspondiente.
  /// Muestra un snackbar en caso de error.
  Future<void> deleteTask() async {
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
        await FirebaseFirestore.instance
            .collection(kTasksCollection)
            .doc(widget.documentId)
            .delete();
      } catch (e) {
        // Verifica si el widget sigue montado
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
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        children: [
          Card(
            elevation: kElevationCard,
            color: kCardsColor,
            child: Padding(
              padding: kPaddingCard,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Información principal de la tarea
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título
                        Text(widget.title, style: kCardTitleStyle),

                        // Descripción con límite de líneas y elipsis
                        Text(
                          widget.description ?? '',
                          style: kDescriptionStyle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // Fecha de vencimiento con color que indica proximidad o vencimiento
                        Builder(
                          builder: (context) {
                            if (widget.dueDate == null) {
                              return Text(
                                'Sin fecha',
                                style: TextStyle(color: Colors.grey),
                              );
                            }

                            final now = DateTime.now();
                            final date = widget.dueDate!.toDate();
                            final difference = date.difference(now).inDays;

                            Color dateColor;
                            if (difference < 2) {
                              dateColor = Colors.red;
                            } else if (difference <= 5) {
                              dateColor = Colors.amber[800]!;
                            } else {
                              dateColor = Colors.green;
                            }

                            return Text(
                              date.isBefore(
                                    DateTime(now.year, now.month, now.day),
                                  )
                                  ? '${DateFormat('dd/MM/yyyy').format(date)} - Vencida'
                                  : DateFormat('dd/MM/yyyy').format(date),
                              style: TextStyle(
                                color: dateColor,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),

                        // Indicadores visuales para prioridad y estado
                        Row(
                          children: [
                            Card(
                              color: _getPriorityColor(widget.priority),
                              child: Padding(
                                padding: kPaddingCard,
                                child: Text(
                                  widget.priority,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            SizedBox(width: 10.0),
                            Card(
                              color: _getStatusColor(widget.status),
                              child: Padding(
                                padding: kPaddingCard,
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

                  // Botones de acción: eliminar, editar, ver detalle
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => deleteTask(),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
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
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.remove_red_eye),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => TaskDetailScreen(
                                    title: widget.title,
                                    description: widget.description,
                                    dueDate: widget.dueDate,
                                    priority: widget.priority,
                                    status: widget.status,
                                    documentId: widget.documentId,
                                  ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
