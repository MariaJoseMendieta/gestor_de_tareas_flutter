import 'package:flutter/material.dart';
import 'package:gestor_de_tareas_flutter/screens/tasks_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); //Prepara Flutter
  await Firebase.initializeApp(); //Conecta con Firebase (autenticación, Firestore, etc.)
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: TasksScreen());
  }
}
