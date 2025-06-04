import 'package:flutter/material.dart';
import 'package:gestor_de_tareas_flutter/screens/tasks_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: TasksScreen());
  }
}
