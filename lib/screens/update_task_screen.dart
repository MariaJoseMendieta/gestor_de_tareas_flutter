import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:gestor_de_tareas_flutter/constants.dart';

final _firestore = FirebaseFirestore.instance;

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
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  DateTime? _selectedDate;
  String _selectedPriority = 'Media';
  String _selectedStatus = 'Pendiente';

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

  void _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<bool> taskTitleExists(String title, String excludeId) async {
    final query =
        await _firestore
            .collection('tasks')
            .where('title', isEqualTo: title.trim())
            .get();

    // Si existe una tarea con ese título y NO es la misma que estamos editando
    return query.docs.any((doc) => doc.id != excludeId);
  }

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
      await _firestore.collection('tasks').doc(widget.documentId).update({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'dueDate':
            _selectedDate != null ? Timestamp.fromDate(_selectedDate!) : null,
        'priority': _selectedPriority,
        'status': _selectedStatus,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Tarea actualizada')));
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Tarea', style: kTextStyleAppBar),
        backgroundColor: kMainColor,
        iconTheme: IconThemeData(
          color: Colors.white, // Cambia esto al color que desees
        ),
      ),
      backgroundColor: kBackgroundColorApp,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Card(
                color: kCardsColor,
                elevation: 5.0,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 2.0),
                  child: TextFormField(
                    controller: _titleController,
                    maxLength: 150,
                    decoration: InputDecoration(
                      labelText: 'Título *',
                      counterText: '',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Este campo es obligatorio';
                      }
                      if (value.length > 150) {
                        return 'Máximo 150 caracteres';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              Card(
                color: kCardsColor,
                elevation: 5.0,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 2.0),
                  child: TextFormField(
                    maxLength: 1000,
                    maxLines: null,
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
                        if (value.trim().length > 1000) {
                          return 'Máximo 1000 caracteres permitidos.';
                        }
                      }
                      return null; // Es opcional
                    },
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 110.0,
                      child: Card(
                        color: kCardsColor,
                        elevation: 5.0,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: ListTile(
                            title: Text(
                              _selectedDate == null
                                  ? 'Fecha de vencimiento \n DD/MM/AAAA'
                                  : 'Fecha de vencimiento ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}',
                              style: TextStyle(fontSize: 15.0),
                            ),
                            trailing: Icon(Icons.calendar_today),
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
                        elevation: 5.0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Prioridad',
                                style: TextStyle(fontSize: 15.0),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: DropdownButtonFormField<String>(
                                dropdownColor: kDropdownColor,
                                isExpanded: true,
                                value: _selectedPriority,
                                items: [
                                  DropdownMenuItem(
                                    value: 'Alta',
                                    child: Text('Alta'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Media',
                                    child: Text('Media'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Baja',
                                    child: Text('Baja'),
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
              SizedBox(height: 10),
              Card(
                color: kCardsColor,
                elevation: 5.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Estado', style: TextStyle(fontSize: 15.0)),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
                      child: DropdownButtonFormField<String>(
                        dropdownColor: kDropdownColor,
                        isExpanded: true,
                        value: _selectedStatus,
                        items: [
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
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: _updateTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kMainColor,
                    ),
                    child: Text(
                      'Guardar Cambios',
                      style: TextStyle(color: Colors.white),
                    ),
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
