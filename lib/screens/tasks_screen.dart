import 'package:flutter/material.dart';
import 'package:gestor_de_tareas_flutter/screens/add_task_screen.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

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
        child: Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddTaskScreen()),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF0569B4)),
            child: Text('Agregar Tarea', style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }
}
