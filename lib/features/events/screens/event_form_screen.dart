import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../core/providers/event_provider.dart';
import '../../../core/providers/category_provider.dart';
import '../../../models/event_model.dart';

class EventFormScreen extends StatefulWidget {
  const EventFormScreen({super.key});

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _date = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now();
  bool _recurring = false;
  String? _selectedCategoryName;

  @override
  void initState() {
    super.initState();
    _endTime = TimeOfDay(hour: (_startTime.hour + 1) % 24, minute: _startTime.minute);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDate: _date,
    );
    if (selected != null) setState(() => _date = selected);
  }

  Future<void> _pickStartTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (selected != null) {
      setState(() {
        _startTime = selected;
        _endTime = TimeOfDay(hour: (_startTime.hour + 1) % 24, minute: _startTime.minute);
      });
    }
  }

  Future<void> _pickEndTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (selected != null) setState(() => _endTime = selected);
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final startDateTime = DateTime(
      _date.year, _date.month, _date.day, _startTime.hour, _startTime.minute,
    );
    var endDateTime = DateTime(
      _date.year, _date.month, _date.day, _endTime.hour, _endTime.minute,
    );
    if (endDateTime.isBefore(startDateTime)) {
      endDateTime = endDateTime.add(const Duration(days: 1));
    }

    final event = EventModel(
      id: const Uuid().v4(),
      title: _titleController.text.trim(),
      start: startDateTime,
      end: endDateTime,
      location: _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      isRecurring: _recurring,
      category: _selectedCategoryName,
    );

    Provider.of<EventProvider>(context, listen: false).addEvent(event);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Evento salvo com sucesso!')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryProvider>().categories;

    return Scaffold(
      appBar: AppBar(title: const Text('Novo evento')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Título
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título *',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Informe o título do evento.' : null,
            ),
            const SizedBox(height: 16),

            // Data
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: const Text('Data'),
              subtitle: Text(
                '${_date.day.toString().padLeft(2, '0')}/'
                '${_date.month.toString().padLeft(2, '0')}/'
                '${_date.year}',
              ),
              trailing: const Icon(Icons.edit_calendar),
              onTap: _pickDate,
            ),

            // Horários
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.schedule),
              title: const Text('Horário inicial'),
              subtitle: Text(_startTime.format(context)),
              onTap: _pickStartTime,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.schedule_outlined),
              title: const Text('Horário final'),
              subtitle: Text(_endTime.format(context)),
              onTap: _pickEndTime,
            ),
            const SizedBox(height: 8),

            // Localização
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Localização',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: 16),

            // Categoria
            DropdownButtonFormField<String>(
              initialValue: _selectedCategoryName,
              decoration: const InputDecoration(
                labelText: 'Categoria',
                prefixIcon: Icon(Icons.label_outline),
              ),
              hint: const Text('Selecionar categoria'),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('Sem categoria'),
                ),
                ...categories.map(
                  (cat) => DropdownMenuItem<String>(
                    value: cat.name,
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: cat.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Text(cat.name),
                      ],
                    ),
                  ),
                ),
              ],
              onChanged: (value) => setState(() => _selectedCategoryName = value),
            ),
            const SizedBox(height: 16),

            // Observações
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Observações',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.notes),
              ),
            ),
            const SizedBox(height: 8),

            // Recorrente
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _recurring,
              onChanged: (value) => setState(() => _recurring = value),
              title: const Text('Evento recorrente'),
              subtitle: const Text('Preparado para recorrência diária, semanal ou mensal.'),
            ),
            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('Salvar evento'),
            ),
          ],
        ),
      ),
    );
  }
}
