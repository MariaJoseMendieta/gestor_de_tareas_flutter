import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestor_de_tareas_flutter/constants.dart';

final _firestore = FirebaseFirestore.instance;

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});
  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();

  final TextEditingController _descController = TextEditingController();

  String _selectedPriority = 'Media';
  String _selectedStatus = 'Pendiente';

  DateTime? _selectedDate;

  void _pickDate() async {
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

  Future<bool> taskTitleExists(String title) async {
    final query =
        await _firestore
            .collection('tasks')
            .where('title', isEqualTo: title)
            .get();
    return query.docs.isNotEmpty;
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final exists = await taskTitleExists(_titleController.text.trim());

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
      await _firestore.collection('tasks').add({
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'dueDate': _selectedDate!,
        'priority': _selectedPriority,
        'status': _selectedStatus,
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kMainColor,
        title: Text('Agregar Tarea', style: kTextStyleAppBar),
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
                      hintText: 'Título *',
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
                    controller: _descController,
                    decoration: InputDecoration(
                      hintText: 'Descripción (opcional)',
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
                        color: Colors.white,
                        elevation: 5.0,
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
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kMainColor,
                    ),
                    child: Text(
                      'Guardar',
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
