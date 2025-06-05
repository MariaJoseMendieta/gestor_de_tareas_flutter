import 'package:flutter/material.dart';
import 'package:gestor_de_tareas_flutter/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:gestor_de_tareas_flutter/screens/task_detail_screen.dart';
import 'package:gestor_de_tareas_flutter/screens/update_task_screen.dart';

class TaskCard extends StatelessWidget {
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
  final String documentId; // ID del documento en Firestore

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

  // Elimina la tarea tras la confirmación del usuario.
  Future<void> deleteTask(BuildContext context) async {
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
            .doc(documentId)
            .delete();
      } catch (e, stack) {
        print('Error al eliminar tarea: $e');
        print(stack);
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: kCardTitleStyle),
                        Text(
                          description ?? '',
                          style: kDescriptionStyle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Builder(
                          builder: (context) {
                            if (dueDate == null) {
                              return Text(
                                'Sin fecha',
                                style: TextStyle(color: Colors.grey),
                              );
                            }

                            final now = DateTime.now();
                            final date = dueDate!.toDate();
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
                        Row(
                          children: [
                            Card(
                              color: _getPriorityColor(priority),
                              child: Padding(
                                padding: kPaddingCard,
                                child: Text(
                                  priority,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            SizedBox(width: 10.0),
                            Card(
                              color: _getStatusColor(status),
                              child: Padding(
                                padding: kPaddingCard,
                                child: Text(
                                  status,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => deleteTask(context),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
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
                                    title: title,
                                    description: description,
                                    dueDate: dueDate,
                                    priority: priority,
                                    status: status,
                                    documentId: documentId,
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
