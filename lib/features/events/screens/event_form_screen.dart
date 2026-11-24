// lib/features/events/screens/event_form_screen.dart
//
// Formulário de criação de eventos do Agendify.
//
// Relatório 11/11: GPS automático — botão detecta localização atual (mobile + web).
// Relatório 24/11: Salva evento de verdade via EventProvider (online + offline).

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../core/providers/event_provider.dart';
import '../../../models/event_model.dart';
import '../../../services/location_service.dart';

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

  final _locationService = LocationService();

  DateTime _date = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now();
  bool _recurring = false;
  bool _loadingLocation = false;
  bool _saving = false;

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
    final selected = await showTimePicker(context: context, initialTime: _startTime);
    if (selected != null) setState(() => _startTime = selected);
  }

  Future<void> _pickEndTime() async {
    final selected = await showTimePicker(context: context, initialTime: _endTime);
    if (selected != null) setState(() => _endTime = selected);
  }

  /// GPS: obtém localização e preenche o campo (com diálogo de confirmação).
  Future<void> _fetchCurrentLocation() async {
    setState(() => _loadingLocation = true);
    try {
      final address = await _locationService.getCurrentAddress();
      if (!mounted) return;

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Localização detectada'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Deseja usar o endereço abaixo como localização do evento?'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(ctx).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        address,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Usar este endereço'),
            ),
          ],
        ),
      );

      if (confirmed == true && mounted) {
        setState(() => _locationController.text = address);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Não foi possível obter a localização: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _loadingLocation = false);
    }
  }

  /// Salva o evento via EventProvider (online: Firebase; offline: SQLite local).
  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _saving = true);

    final startDt = DateTime(
      _date.year, _date.month, _date.day,
      _startTime.hour, _startTime.minute,
    );
    final endDt = DateTime(
      _date.year, _date.month, _date.day,
      _endTime.hour, _endTime.minute,
    );

    final event = EventModel(
      id: const Uuid().v4(),
      title: _titleController.text.trim(),
      start: startDt,
      end: endDt.isBefore(startDt) ? startDt.add(const Duration(hours: 1)) : endDt,
      location: _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      isRecurring: _recurring,
    );

    try {
      final provider = context.read<EventProvider>();
      await provider.addEvent(event);

      if (!mounted) return;
      final offline = provider.isOffline;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            offline
                ? 'Evento salvo localmente. Será sincronizado ao reconectar.'
                : 'Evento salvo com sucesso!',
          ),
          backgroundColor: offline
              ? Theme.of(context).colorScheme.tertiary
              : Theme.of(context).colorScheme.primary,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar evento: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOffline = context.watch<EventProvider>().isOffline;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo evento'),
        actions: [
          if (isOffline)
            Tooltip(
              message: 'Sem conexão — evento será salvo localmente',
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  Icons.cloud_off,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Banner offline
            if (isOffline)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.wifi_off,
                        color: Theme.of(context).colorScheme.onErrorContainer, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Sem conexão. O evento será salvo localmente e sincronizado quando a internet retornar.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Título
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe o título do evento.';
                }
                return null;
              },
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

            // ─── Campo de localização com GPS ──────────────────────────────
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Localização',
                prefixIcon: const Icon(Icons.location_on_outlined),
                suffixIcon: _loadingLocation
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        tooltip: 'Usar minha localização atual',
                        icon: const Icon(Icons.my_location),
                        onPressed: _fetchCurrentLocation,
                      ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const SizedBox(width: 4),
                Icon(Icons.info_outline,
                    size: 14, color: Theme.of(context).colorScheme.outline),
                const SizedBox(width: 4),
                Text(
                  'Toque em  para detectar sua posição atual via GPS.',
                  style: TextStyle(
                      fontSize: 11, color: Theme.of(context).colorScheme.outline),
                ),
              ],
            ),
            // ──────────────────────────────────────────────────────────────

            const SizedBox(height: 16),
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
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _recurring,
              onChanged: (value) => setState(() => _recurring = value),
              title: const Text('Evento recorrente'),
              subtitle: const Text(
                  'Preparado para recorrência diária, semanal ou mensal.'),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.save),
              label: Text(_saving ? 'Salvando...' : 'Salvar evento'),
            ),
          ],
        ),
      ),
    );
  }
}
