import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestor_de_tareas_flutter/screens/add_task_screen.dart';
import 'package:intl/intl.dart';
import 'package:gestor_de_tareas_flutter/screens/task_detail_screen.dart';
import 'package:gestor_de_tareas_flutter/constants.dart';
import 'package:gestor_de_tareas_flutter/screens/update_task_screen.dart';

final _firestore = FirebaseFirestore.instance;

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  String? _selectedPriority;
  String? _selectedStatus;
  String? _selectedDueDate;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kMainColor,
        title: Text('Gestor de Tareas', style: kTextStyleAppBar),
      ),
      backgroundColor: kBackgroundColorApp,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: _selectedPriority,
                      hint: Text('Prioridad'),
                      items: [
                        DropdownMenuItem(value: 'Todas', child: Text('Todas')),
                        DropdownMenuItem(value: 'Alta', child: Text('Alta')),
                        DropdownMenuItem(value: 'Media', child: Text('Media')),
                        DropdownMenuItem(value: 'Baja', child: Text('Baja')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedPriority = value;
                          });
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 10.0),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: _selectedStatus,
                      hint: Text('Estado'),
                      items: [
                        DropdownMenuItem(value: 'Todas', child: Text('Todas')),
                        DropdownMenuItem(
                          value: 'Pendiente',
                          child: Text('Pendiente'),
                        ),
                        DropdownMenuItem(
                          value: 'En Progreso',
                          child: Text('En Progreso'),
                        ),
                        DropdownMenuItem(
                          value: 'Completada',
                          child: Text('Completada'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedStatus = value;
                          });
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 10.0),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: _selectedDueDate,
                      hint: Text('Vencimiento'),
                      items: [
                        DropdownMenuItem(value: 'Todas', child: Text('Todas')),
                        DropdownMenuItem(
                          value: 'Menos 2 días',
                          child: Text('Menos 2 días'),
                        ),
                        DropdownMenuItem(
                          value: 'Menos 5 días',
                          child: Text('Menos 5 días'),
                        ),
                        DropdownMenuItem(
                          value: 'Más 5 días',
                          child: Text('Más 5 días'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedDueDate = value;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            TasksStream(
              selectedPriority: _selectedPriority,
              selectedStatus: _selectedStatus,
              selectedDueDate: _selectedDueDate,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddTaskScreen()),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: kMainColor),
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
  const TasksStream({
    super.key,
    this.selectedPriority,
    this.selectedStatus,
    this.selectedDueDate,
  });

  final String? selectedPriority;
  final String? selectedStatus;
  final String? selectedDueDate;

  // Filtrar las tareas según cuánto tiempo falta para su fecha de vencimiento
  bool _shouldIncludeTask(Timestamp? dueDate) {
    if (selectedDueDate == null) return true;
    if (dueDate == null) return false;

    final now = DateTime.now();
    final date = dueDate.toDate();
    final difference = date.difference(now).inDays;

    switch (selectedDueDate) {
      case 'Menos 2 días':
        return difference < 2;
      case 'Menos 5 días':
        return difference < 5;
      case 'Más 5 días':
        return difference >= 5;
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      //Escucha la colección 'task' ordenada por 'timestamp' para actualizaciones en tiempo real
      stream: _firestore.collection('tasks').snapshots(),
      builder: (context, snapshot) {
        //Mostrar indicador de carga mientras no hay datos
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(backgroundColor: kMainColor),
          );
        }

        // Acceder a los documentos recibidos de Firestore (Obtener todas las tareas)
        final allTasks = snapshot.data!.docs.toList();
        //Filtrar las tareas una por una
        final filteredTasks =
            allTasks.where((task) {
              final data = task.data() as Map<String, dynamic>;

              // Extraer cada campo relevante
              final priority = data['priority'];
              final status = data['status'];
              final dueDate = data['dueDate'] as Timestamp?;

              // Verificar si cumple con el filtro de prioridad
              final cumplePrioridad =
                  (selectedPriority == null || selectedPriority == 'Todas')
                      ? true
                      : selectedPriority == priority;

              // Verificar si cumple con el filtro de estado
              final cumpleEstado =
                  (selectedStatus == null || selectedStatus == 'Todas')
                      ? true
                      : selectedStatus == status;

              // Verificar si cumple con el filtro de vencimiento
              final cumpleVencimiento = _shouldIncludeTask(dueDate);

              // Incluir solo si cumple con los 3 filtros
              return cumplePrioridad && cumpleEstado && cumpleVencimiento;
            }).toList();

        // Ordenar cronológicamente de la tarea más próxima a la más lejana.
        // Devuelve: -1 si a debe ir antes que b, 0 si son iguales y 1 si a debe ir después que b
        filteredTasks.sort((a, b) {
          //Extrae los datos del documento a y b en forma de un mapa
          final dataA = a.data() as Map<String, dynamic>;
          final dataB = b.data() as Map<String, dynamic>;

          // Extrae la fecha de vencimiento del documento a y b, la cual es de tipo Timestamp de Firebase.
          final dueDateA = dataA['dueDate'] as Timestamp?;
          final dueDateB = dataB['dueDate'] as Timestamp?;

          // Si ambas tareas no tienen fecha, se consideran iguales → no se cambia el orden
          if (dueDateA == null && dueDateB == null) return 0;
          // Si a no tiene fecha, se envía al final.
          if (dueDateA == null) return 1;
          //Si b no tiene fecha, se envía al final.
          if (dueDateB == null) return -1;

          return dueDateA.toDate().compareTo(dueDateB.toDate());
        });

        // Crear las tarjetas de tarea a partir del resultado filtrado
        final taskCards =
            filteredTasks.map((task) {
              final data = task.data() as Map<String, dynamic>;

              return TaskCard(
                title: data['title'],
                description: data['description'],
                dueDate: data['dueDate'],
                priority: data['priority'],
                status: data['status'],
                documentId: task.id,
              );
            }).toList();

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
  void deleteTask(BuildContext context) async {
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
      try {
        await _firestore.collection('tasks').doc(documentId).delete();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Tarea eliminada')));
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al eliminar')));
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
            elevation: 5.0,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
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
