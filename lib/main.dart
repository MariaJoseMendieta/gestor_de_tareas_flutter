/*
=======================================================================
main.dart

Este archivo es el punto de entrada de la aplicación Flutter.
Se encarga de:
- Inicializar correctamente el entorno de Flutter.
- Conectarse a Firebase (para utilizar servicios como Firestore).
- Ejecutar el widget raíz [MyApp], que muestra la pantalla principal.
=======================================================================
*/

import 'package:flutter/material.dart'; // Paquete base para construir interfaces en Flutter.
import 'package:gestor_de_tareas_flutter/screens/tasks_screen.dart'; // Importa la pantalla principal de tareas.
import 'package:firebase_core/firebase_core.dart'; // Permite inicializar Firebase en la app.

void main() async {
  // Asegura que Flutter esté completamente inicializado antes de usar funciones asincrónicas.
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializa la conexión con Firebase.
  await Firebase.initializeApp();
  // Lanza la aplicación y muestra el widget raíz [MyApp].
  runApp(const MyApp());
}

/// Widget raíz de la aplicación.
///
/// Construye una aplicación [MaterialApp] con [TasksScreen] como pantalla principal.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Define la pantalla principal como TasksScreen.
    return MaterialApp(home: TasksScreen());
  }
}
