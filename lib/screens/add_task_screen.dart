/*
=============================================================================
add_tasks_screen.dart

Esta pantalla permite al usuario crear y registrar nuevas tareas
en una colección de Firestore. La tarea incluye título, descripción,
fecha de vencimiento, prioridad y estado. También valida entradas
y evita duplicados por título.
=============================================================================
*/

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestor_de_tareas_flutter/constants.dart';

/// Referencia a la instancia principal de Firestore
final _firestore = FirebaseFirestore.instance;

/// Pantalla principal que permite agregar una nueva tarea
class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});
  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  // Crea una clave única para identificar y acceder al estado del formulario.
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto para los campos de entrada del formulario.
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  // Guarda la prioridad y estado seleccionado por el usuario
  String _selectedPriority = kPriorityMedia;
  String _selectedStatus = kStatusPendiente;

  // Almacena la fecha de vencimiento seleccionada por el usuario
  DateTime? _selectedDate;

  /// Abre un DatePicker para seleccionar la fecha de vencimiento
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  /// Verifica si ya existe una tarea con el mismo título
  Future<bool> taskTitleExists(String title) async {
    final query =
        await _firestore
            .collection(kTasksCollection)
            .where('title_lowercase', isEqualTo: title.toLowerCase().trim())
            .get();
    return query.docs.isNotEmpty;
  }

  /// Valida el formulario y guarda la tarea en Firestore
  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final exists = await taskTitleExists(_titleController.text.trim());

      // Asegura de que el widget aún está en el árbol antes de usar context
      if (!mounted) return;
      if (exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ya existe una tarea con ese título')),
        );
        return; // No guardar
      }
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Por favor selecciona una fecha de vencimiento'),
          ),
        );
        return;
      }
      //Añadir la tarea a la colección 'tasks' en Firestore
      await _firestore.collection(kTasksCollection).add({
        'title': _titleController.text.trim(),
        'title_lowercase': _titleController.text.toLowerCase().trim(),
        'description': _descController.text.trim(),
        'dueDate': _selectedDate!,
        'priority': _selectedPriority,
        'status': _selectedStatus,
      });
      // Asegura de que el widget aún está en el árbol antes de usar context
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  /// Construcción del widget principal de la pantalla
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kMainColor,
        title: Text('Agregar Tarea', style: kTextStyleAppBar),
        iconTheme: kIconThemeColor,
      ),
      backgroundColor: kBackgroundColorApp,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Campo Título
              Card(
                color: kCardsColor,
                elevation: kElevationCard,
                child: Padding(
                  padding: kPaddingTitleDesc,
                  child: TextFormField(
                    controller: _titleController,
                    maxLength: kMaxLengthTitle,
                    decoration: InputDecoration(
                      hintText: 'Título *',
                      counterText: '',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Este campo es obligatorio';
                      }
                      if (value.length > kMaxLengthTitle) {
                        return 'Máximo 150 caracteres';
                      }
                      return null;
                    },
                  ),
                ),
              ),

              // Campo Descripción
              Card(
                color: kCardsColor,
                elevation: kElevationCard,
                child: Padding(
                  padding: kPaddingTitleDesc,
                  child: TextFormField(
                    maxLength: kMaxLengthDes,
                    maxLines: 4,
                    controller: _descController,
                    decoration: InputDecoration(
                      hintText: 'Descripción (opcional)',
                      counterText: '',
                    ),
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty) {
                        if (value.trim().length > kMaxLengthDes) {
                          return 'Máximo 1000 caracteres permitidos.';
                        }
                      }
                      return null; // Es opcional
                    },
                  ),
                ),
              ),

              // Fecha y Prioridad
              Row(
                children: [
                  // Selección de fecha
                  Expanded(
                    child: SizedBox(
                      height: 110.0,
                      child: Card(
                        color: kCardsColor,
                        elevation: kElevationCard,
                        child: Center(
                          child: ListTile(
                            title: Text(
                              _selectedDate == null
                                  ? 'Fecha de vencimiento \nDD/MM/AAAA'
                                  : 'Fecha de vencimiento ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}',
                              style: TextStyle(fontSize: 15.0),
                            ),
                            trailing: Icon(Icons.calendar_today, size: 22.0),
                            onTap: _pickDate,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Selector de prioridad
                  Expanded(
                    child: SizedBox(
                      height: 110.0,
                      child: Card(
                        color: kCardsColor,
                        elevation: kElevationCard,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: kPaddingDropPriority,
                              child: Text(
                                'Prioridad',
                                style: TextStyle(fontSize: 15.0),
                              ),
                            ),
                            Padding(
                              padding: kPaddingDropPriority,
                              child: DropdownButtonFormField<String>(
                                dropdownColor: kDropdownColor,
                                isExpanded: true,
                                value: _selectedPriority,
                                items: [
                                  DropdownMenuItem(
                                    value: kPriorityAlta,
                                    child: Text(kPriorityAlta),
                                  ),
                                  DropdownMenuItem(
                                    value: kPriorityMedia,
                                    child: Text(kPriorityMedia),
                                  ),
                                  DropdownMenuItem(
                                    value: kPriorityBaja,
                                    child: Text(kPriorityBaja),
                                  ),
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
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Selector de estado
              Card(
                color: kCardsColor,
                elevation: kElevationCard,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Estado', style: TextStyle(fontSize: 15.0)),
                    ),
                    Padding(
                      padding: kPaddingDropStatus,
                      child: DropdownButtonFormField<String>(
                        dropdownColor: kDropdownColor,
                        isExpanded: true,
                        value: _selectedStatus,
                        items: [
                          DropdownMenuItem(
                            value: kStatusPendiente,
                            child: Text(kStatusPendiente),
                          ),
                          DropdownMenuItem(
                            value: kStatusEnProgreso,
                            child: Text(kStatusEnProgreso),
                          ),
                          DropdownMenuItem(
                            value: kStatusCompletada,
                            child: Text(kStatusCompletada),
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
                  ],
                ),
              ),

              // Botón de Guardar
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kMainColor,
                    ),
                    child: Text('Guardar', style: kTextStyleButton),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
