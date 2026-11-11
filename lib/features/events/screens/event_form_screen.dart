// lib/features/events/screens/event_form_screen.dart
//
// Formulário de criação de eventos do Agendify.
//
// Atualização 11/11/2026:
//   - Adicionado botão "Usar minha localização atual" no campo de localização.
//   - Suporte a mobile (GPS nativo) e web (Geolocation API do browser).
//   - Usuário pode aceitar a sugestão automática ou digitar manualmente.

import 'package:flutter/material.dart';

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

  /// Indica se a busca de localização está em andamento.
  bool _loadingLocation = false;

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

    if (selected != null) {
      setState(() => _date = selected);
    }
  }

  Future<void> _pickStartTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );

    if (selected != null) {
      setState(() => _startTime = selected);
    }
  }

  Future<void> _pickEndTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );

    if (selected != null) {
      setState(() => _endTime = selected);
    }
  }

  /// Obtém a localização atual do dispositivo/navegador e preenche o campo.
  /// Em dispositivos móveis solicita permissão ao SO quando necessário.
  /// No navegador (web) o browser mostra o diálogo nativo de permissão.
  Future<void> _fetchCurrentLocation() async {
    setState(() => _loadingLocation = true);

    try {
      final address = await _locationService.getCurrentAddress();

      if (!mounted) return;

      // Mostra diálogo de confirmação — o usuário pode aceitar ou cancelar.
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Localização detectada'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Deseja usar o endereço abaixo como localização do evento?',
              ),
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
          content: Text(
            'Não foi possível obter a localização: ${e.toString()}',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _loadingLocation = false);
    }
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // TODO: transformar formulário em EventModel e salvar com EventService.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Evento salvo no protótipo.')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo evento'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
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

            // ─── Campo de localização com sugestão automática ───────────────
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
            // Dica contextual abaixo do campo
            Row(
              children: [
                const SizedBox(width: 4),
                Icon(
                  Icons.info_outline,
                  size: 14,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(width: 4),
                Text(
                  'Toque em  para detectar sua posição atual.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
            // ───────────────────────────────────────────────────────────────

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
                'Preparado para recorrência diária, semanal ou mensal.',
              ),
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
