import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestor_de_tareas_flutter/screens/add_task_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        children: [
          //Mostrar el email del remitente encima del mensaje
          Material(
            elevation: 5.0,
            color: Color(0xFFDCEDC8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 20.0,
                    ),
                    child: Text(
                      title,
                      style: TextStyle(fontSize: 15.0, color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
