import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestor_de_tareas_flutter/screens/add_task_screen.dart';
import 'package:intl/intl.dart';
import 'package:gestor_de_tareas_flutter/screens/task_detail_screen.dart';

final _firestore = FirebaseFirestore.instance;

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0569B4),
        title: Text(
          'Gestor de Tareas',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: Color(0xFFF5FAFA),
      body: SafeArea(
        child: Column(
          children: [
            TasksStream(),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddTaskScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0569B4),
              ),
              child: Text(
                'Agregar Tarea',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TasksStream extends StatelessWidget {
  const TasksStream({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      //Escucha la colección 'task' ordenada por 'timestamp' para actualizaciones en tiempo real
      stream: _firestore.collection('tasks').snapshots(),
      builder: (context, snapshot) {
        //Mostrar indicador de carga mientras no hay datos
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Color(0xFF0569B4),
            ),
          );
        }

        // Acceder a los documentos recibidos de Firestore
        final tasks = snapshot.data!.docs.reversed;
        List<TaskCard> taskCards = [];
        for (var task in tasks) {
          final taskTitle = task['title'];
          final taskDescription = task['description'];
          final taskDueDate = task['dueDate'];
          final taskPriority = task['priority'];
          final taskStatus = task['status'];

          final taskBubble = TaskCard(
            title: taskTitle,
            description: taskDescription,
            dueDate: taskDueDate,
            priority: taskPriority,
            status: taskStatus,
          );
          taskCards.add(taskBubble);
        }

        return Expanded(
          child: ListView(
            reverse: false,
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            children: taskCards,
          ),
        );
      },
    );
  }
}

class TaskCard extends StatelessWidget {
  // Crea un nuevo [TaskBubble] para representar una tarea.
  const TaskCard({
    super.key,
    required this.title,
    this.description,
    this.dueDate,
    this.priority = 'Media',
    this.status = 'Pendiente',
  });

  final String title;
  final String? description;
  final Timestamp? dueDate;
  final String priority;
  final String status;

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
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        children: [
          //Mostrar el email del remitente encima del mensaje
          Card(
            elevation: 5.0,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          description ?? '',
                          style: TextStyle(color: Colors.grey),
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
                              DateFormat('dd/MM/yyyy').format(date),
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
                                padding: const EdgeInsets.all(8.0),
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
                                padding: const EdgeInsets.all(8.0),
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
                    children: [
                      IconButton(icon: Icon(Icons.delete), onPressed: () {}),
                      IconButton(icon: Icon(Icons.edit), onPressed: () {}),
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
