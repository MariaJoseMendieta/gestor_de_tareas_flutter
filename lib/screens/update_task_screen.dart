/*
=============================================================================
update_tasks_screen.dart

Esta pantalla permite al usuario editar una tarea existente en Firestore,
actualizando su título, descripción, fecha de vencimiento, prioridad y estado.
Incluye validaciones y verificación de duplicados por título.
Utiliza Firestore como backend y presenta un formulario con campos adaptados
a los datos ya registrados de la tarea seleccionada.
=============================================================================
*/

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:gestor_de_tareas_flutter/constants.dart';

// Referencia global a Firestore
final _firestore = FirebaseFirestore.instance;

/// Pantalla para editar tareas existentes.
/// Esta pantalla recibe los datos de la tarea seleccionada y permite modificarlos.
class UpdateTaskScreen extends StatefulWidget {
  const UpdateTaskScreen({
    super.key,
    required this.documentId,
    required this.title,
    this.description,
    this.dueDate,
    this.priority = 'Media',
    this.status = 'Pendiente',
  });

  final String documentId;
  final String title;
  final String? description;
  final Timestamp? dueDate;
  final String priority;
  final String status;

  @override
  State<UpdateTaskScreen> createState() => _UpdateTaskScreenState();
}

class _UpdateTaskScreenState extends State<UpdateTaskScreen> {
  // Llave para el formulario, permite validarlo y controlarlo
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto para título y descripción
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  // Fecha seleccionada por el usuario
  DateTime? _selectedDate;

  // Valores seleccionados por defecto para prioridad y estado
  String _selectedPriority = kPriorityMedia;
  String _selectedStatus = kStatusPendiente;

  /// Inicializa los controladores con los valores actuales de la tarea
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
    _descriptionController = TextEditingController(
      text: widget.description ?? '',
    );
    _selectedDate = widget.dueDate?.toDate();
    _selectedPriority = widget.priority;
    _selectedStatus = widget.status;
  }

  /// Muestra un selector de fecha al usuario
  void _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate:
          (_selectedDate != null && _selectedDate!.isBefore(now))
              ? _selectedDate!
              : now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  /// 🔎 Verifica si ya existe una tarea con el mismo título (ignorando la actual)
  Future<bool> taskTitleExists(String title, String excludeId) async {
    final query =
        await _firestore
            .collection(kTasksCollection)
            .where('title_lowercase', isEqualTo: title.toLowerCase().trim())
            .get();

    // Si existe una tarea con ese título y NO es la misma que estamos editando
    return query.docs.any((doc) => doc.id != excludeId);
  }

  /// Actualiza la tarea en Firestore luego de validar el formulario
  Future<void> _updateTask() async {
    // Verificar si el título ya existe en otra tarea
    final exists = await taskTitleExists(
      _titleController.text.trim(),
      widget.documentId,
    );

    // Asegura de que el widget aún está en el árbol antes de usar context
    if (!mounted) return;

    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ya existe otra tarea con ese título')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      await _firestore
          .collection(kTasksCollection)
          .doc(widget.documentId)
          .update({
            'title': _titleController.text.trim(),
            'title_lowercase': _titleController.text.toLowerCase().trim(),
            'description': _descriptionController.text.trim(),
            'dueDate':
                _selectedDate != null
                    ? Timestamp.fromDate(_selectedDate!)
                    : null,
            'priority': _selectedPriority,
            'status': _selectedStatus,
          });

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Tarea actualizada')));

      // Regresa a la pantalla principal
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Tarea', style: kTextStyleAppBar),
        backgroundColor: kMainColor,
        iconTheme: kIconThemeColor,
      ),
      backgroundColor: kBackgroundColorApp,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Campo de título
              Card(
                color: kCardsColor,
                elevation: kElevationCard,
                child: Padding(
                  padding: kPaddingTitleDesc,
                  child: TextFormField(
                    controller: _titleController,
                    maxLength: kMaxLengthTitle,
                    decoration: InputDecoration(
                      labelText: 'Título *',
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

              // Campo de descripción
              Card(
                color: kCardsColor,
                elevation: kElevationCard,
                child: Padding(
                  padding: kPaddingTitleDesc,
                  child: TextFormField(
                    maxLength: kMaxLengthDes,
                    maxLines: 4,
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Descripción (opcional)',
                      counterText: '',
                    ),
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty) {
                        // if (value.trim().length < 500) {
                        //   return 'Se recomienda una descripción de al menos 500 caracteres.';
                        // }
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
                                  ? 'Fecha de vencimiento \n DD/MM/AAAA'
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

              // Estado
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

              // Botón de guardar cambios
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: _updateTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kMainColor,
                    ),
                    child: Text('Guardar Cambios', style: kTextStyleButton),
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
