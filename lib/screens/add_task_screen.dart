import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddTaskScreen extends StatefulWidget {
  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  //const AddTaskScreen({super.key});
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0569B4),
        title: Text(
          'Agregar Tarea',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: Color(0xFFF5FAFA),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            Column(
              children: [
                Card(
                  color: Colors.white,
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
                        // if (existingTitles
                        //     .map((e) => e.toLowerCase())
                        //     .contains(value.trim().toLowerCase())) {
                        //   return 'Este título ya existe';
                        // }
                        return null;
                      },
                    ),
                  ),
                ),
                Card(
                  color: Colors.white,
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
                          color: Colors.white,
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
                  color: Colors.white,
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
                      onPressed: () {
                        // if (_formKey.currentState!.validate()) {
                        //   final newTask = Task(
                        //     title: _titleController.text,
                        //     description: _descController.text,
                        //     //dueDate: _selectedDate,
                        //     priority: _selectedPriority,
                        //     status: _selectedStatus,
                        //   );
                        //Navigator.of(context).pop();
                        //}
                        // if (_formKey.currentState!.validate()) {
                        //   // ✅ Aquí puedes guardar la tarea, ya que es válida
                        //   ScaffoldMessenger.of(context).showSnackBar(
                        //     SnackBar(
                        //       content: Text('Tarea guardada exitosamente'),
                        //     ),
                        //   );
                        Navigator.pop(context);

                        //}
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
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
          ],
        ),
      ),
    );
  }
}
